module CampfireBot
  class Message < ActiveSupport::HashWithIndifferentAccess
    def initialize(attributes)
      self.merge!(attributes)
      self[:message] = self['body'] if !!self['body']
      self[:person] = self['user']['name'] if !!self['user']
      self[:room] = attributes[:room]
    end
    
    def reply(str)
      speak(str)
    end
    
    def speak(str)
      self[:room].speak(str)
    end
    
    def paste(str)
      self[:room].paste(str)
    end
    
    def upload(file_path)
      self[:room].upload(file_path)
    end
    
    def play(str)
      self[:room].play(str)
    end
    
    def html(str)
      html_to_campfire_messages(str).each do |message|
        if message =~ /\n/m
          paste(message)
        else
          speak(message)
        end
      end
    end
  
  private
  
    def html_to_campfire_messages(html)
      parser = HTMLToCampfireParser.new
      parser.feed(html)
      return parser.to_campfire
    end
  
  end
end
