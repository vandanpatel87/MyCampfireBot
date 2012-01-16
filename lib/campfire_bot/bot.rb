#!/usr/bin/ruby

if ENV['RAILS_ENV'].nil?
  ENV['RAILS_ENV'] = 'development'
end

require File.join(File.dirname(__FILE__),'..','..',"config","environment")

# External Libs
require 'rubygems'
require 'yaml'
require 'eventmachine'
require 'logging'
require 'fileutils'
require 'tinder'

# Local Libs
require "campfire_bot/message"
require "campfire_bot/event"
require "campfire_bot/plugin"
require "campfire_bot/campfire_sgml_parser"
require "campfire_bot/html_to_campfire_parser"
require "campfire_bot/speaker"

module CampfireBot
  class Bot
    # this is necessary so the room and campfire objects can be accessed by plugins.
    include Singleton
    
    MAX_RETRIES = 5

    # FIXME - these will be invalid if disconnected. handle this.
    attr_reader :campfire, :rooms, :config, :log

    def initialize
      if BOT_ENVIRONMENT.nil?
        puts "you must specify a BOT_ENVIRONMENT"
        exit 1
      end
      @timeouts = 0
      @config   = YAML.load_file(Rails.root.join(*%w[config campfire_bot config.yml]))[BOT_ENVIRONMENT]
      @rooms    = {}
      @root_logger = Logging.logger["CampfireBot"]
      @log = Logging.logger[self]
      
      # TODO much of this should be configurable per environment
      @root_logger.add_appenders Logging.appenders.rolling_file(Rails.root.join(*%W[log bot_#{BOT_ENVIRONMENT}.log]), 
                            :layout => Logging.layouts.pattern(:pattern => "%d | %-6l | %-12c | %m\n"),
                            :keep => 7)
      @root_logger.level = @config['log_level'] rescue :info
      @root_logger.info("starting")
    end

    def connect
      load_plugins unless !@config['enable_plugins']
      begin
        join_rooms
      rescue Errno::ENETUNREACH, SocketError => e
        @log.fatal "We had trouble connecting to the network: #{e.class}: #{e.message}"
        abort "We had trouble connecting to the network: #{e.class}: #{e.message}"
      rescue Exception => e
        @log.fatal "Unhandled exception while joining rooms: #{e.class}: #{e.message} \n #{$!.backtrace.join("\n")}"
        abort "Unhandled exception while joining rooms: #{e.class}: #{e.message} \n #{$!.backtrace.join("\n")}"
      end  
    end

    def run(interval = 5)
      retry_count = 0
      last_exception_class = nil
      
      catch(:stop_listening) do
        trap('INT') { throw :stop_listening }
        
        # since room#listen blocks, stick it in its own thread
        @rooms.each_pair do |room_name, room|
          Thread.new do
            begin
              room.listen(:timeout => 8) do |raw_msg|
                handle_message(CampfireBot::Message.new(raw_msg.merge({:room => room})))
              end
            rescue Exception => e
              retry_count = 0 if last_exception_class == e.class.to_s
              
              if retry_count < MAX_RETRIES
                retry_count += 1
                last_exception_class = e.class.to_s
                sleep(10)
                room.join
                retry
              else
                trace = e.backtrace.join("\n")
                abort "something went wrong! #{e.message}\n #{trace}"
              end
            end
          end
        end

        loop do
          begin
            @rooms.each_pair do |room_name, room|

              # I assume if we reach here, all the network-related activity has occured successfully
              # and that we're outside of the retry-cycle
              @timeouts = 0

              # Here's how I want it to look
              # @room.listen.each { |m| EventHandler.handle_message(m) }
              # EventHanlder.handle_time(optional_arg = Time.now)

              # Run time-oriented events
              Plugin.registered_intervals.each  do |handler| 
                begin
                  handler.run(CampfireBot::Message.new(:room => room))
                rescue
                  @log.error "error running #{handler.inspect}: #{$!.class}: #{$!.message} \n #{$!.backtrace.join("\n")}"
                end
              end

              Plugin.registered_times.each_with_index  do |handler, index| 
                begin
                  Plugin.registered_times.delete_at(index) if handler.run
                rescue
                  @log.error "error running #{handler.inspect}: #{$!.class}: #{$!.message}, \n #{$!.backtrace.join("\n")}"
                end
              end

            end
            STDOUT.flush
            sleep interval
          rescue Timeout::Error => e
            @log.error("received timeout #{e} #{e.backtrace.join("\n")}")
            if @timeouts < 5
              sleep(5 * @timeouts)
              @timeouts += 1
              retry
            else
              raise e.message
            end
          end
        end
      end
    end

    private

    def join_rooms
      join_rooms_as_user
      @log.info "Joined all rooms."
    end
    
    def join_rooms_as_user
      @campfire = Tinder::Campfire.new(@config['site'], :ssl => @config['use_ssl'], :token => @config['api_key'])

      @config['rooms'].each do |room_name|
        @rooms[room_name] = @campfire.find_room_by_name(room_name)
        raise Exception.new("couldn't find a room named #{room_name}!") if @rooms[room_name].nil?
        res = @rooms[room_name].join
      end
    end

    def load_plugins
      (@config['enable_plugins'] || []).each do |plugin_name|
        load File.join(File.dirname(__FILE__), %W[plugins #{plugin_name}.rb])
      end

      (@config['enable_custom_plugins'] || []).each do |plugin_name|
        load File.join(File.dirname(__FILE__), %W[#{@config['custom_plugins_path']} #{plugin_name}.rb])
      end

      # And instantiate them
      Plugin.registered_plugins.each_pair do |name, klass|
        @log.info "loading plugin: #{name}"
        STDOUT.flush
        Plugin.registered_plugins[name] = klass.new
      end
    end

    def handle_message(message)
      # puts message.inspect

      case message[:type]
      when "KickMessage"
        if message[:user][:id] == @campfire.me[:id]
          @log.info "got kicked... rejoining after 10 seconds"
          sleep 10
          join_rooms_as_user
          @log.info "rejoined room." 
          return
        end
      when "TimestampMessage", "AdvertisementMessage"
        return
      when "TextMessage", "PasteMessage", "SoundMessage"
        # only process non-bot messages
        unless message[:user][:id] == @campfire.me[:id]
          @log.info "#{message[:person]} | #{message[:message]}"
          %w(commands speakers messages).each do |type|
            Plugin.send("registered_#{type}").each do |handler|
              begin
                handler.run(message)
              rescue Exception => e
                @log.error "error running #{handler.inspect}: #{$!.class}: #{$!.message} \n #{$!.backtrace.join("\n")}"
              end
            end
          end
        end
      else
        @log.debug "got message of type #{message['type']} -- discarding"
      end
    end
  end
end

def bot
  CampfireBot::Bot.instance
end
