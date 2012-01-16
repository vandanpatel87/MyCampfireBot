require 'rubygems'
require 'feed-normalizer'
require 'open-uri'
require 'time'

# Sample config
# team_city_rss:
#   url: 'http://teamcity.example/httpAuth/feed.html?itemsType=builds&buildStatus=successful&buildStatus=failed&userKey=feed'
#   username: jsmith
#   password: password
#   deploy_branch: dev
#   ignored_configurations: #configures you don't care about being red
#     - 'experimental'
module TeamCity
  class Build
    attr_accessor :build_number, :project_name, :configuration_name, :timestamp, :success
    
    def initialize(options={})
      self.build_number = options[:build_number]
      self.project_name = options[:project_name]
      self.configuration_name = options[:configuration_name]
      self.timestamp = options[:timestamp]
      self.success = options[:success]
    end
    
    alias :success? :success
    
    def failure?
      !success?
    end
    
    class << self
      def from_feed_entry(entry)
        match = entry.title.match(/Build (.*?)::(.*?) #(\d+) (.*)/)
        success = !!(match[4] =~ /success/)
        new(:build_number => match[3].to_i, :project_name => match[1], :configuration_name => match[2], :timestamp => entry.date_published, :success => success)
      end
    end
  end
  
  class Project
    attr_reader :name, :configurations
    
    def initialize(name)
      @name = name
      @configurations = {}
    end
    
    def add_build(build)
      @configurations[build.configuration_name] ||= Configuration.new(build.configuration_name)
      @configurations[build.configuration_name].add_build(build)
    end
    
    def configuration(configuration_name)
      return @configurations[configuration_name.to_s]
    end
    
    def configurations
      return @configurations.values
    end
    
    def failed_configurations
      return configurations.select { |configuration| !configuration.success? }
    end
    
    def success?
      return configurations.all? { |configuration| configuration.success? }
    end
  end
  
  class Configuration
    attr_reader :name, :builds
    
    def initialize(name)
      @name = name
    end
    
    def add_build(build)
      @builds ||= []
      @builds << build
      @builds = @builds.sort_by(&:build_number)
    end
    
    def latest_build
      return builds.last
    end
    
    def success?
      return latest_build.success?
    end    
  end
  
  class ProjectManager
    attr_reader :projects

    def initialize
      @projects = {}
    end
    
    def add_build(build)
      @projects[build.project_name] ||= Project.new(build.project_name)
      @projects[build.project_name].add_build(build)
    end
    
    def project(project_name)
      return @projects[project_name.to_s]
    end
    
    def projects
      return @projects.values
    end    
  end
end

class TeamCityRss < CampfireBot::Plugin

  on_command 'check tc', :turn_on_tc_monitor
  on_command 'no check tc', :turn_off_tc_monitor
  at_interval 1.hour, :check_tc_status
  
  def monitor_tc?
    @monitor_tc ||= false
  end
  
  def turn_on_tc_monitor(msg)
    @monitor_tc = true
    msg.speak("GL!") if check_tc_status(msg)
  end
  
  def turn_off_tc_monitor(msg)
    @monitor_tc = false
    msg.speak("Canceling teamcity notifications... slackers")
  end
  
  def check_tc_status(msg)
    return unless monitor_tc?

    refresh
    tc_was_green = if deploy_project.success?
      true
    else
      msg.speak(":warning: Deploy scheduled but #{deploy_branch} is RED on TeamCity")
      msg.speak("Failures on: " + deploy_project.failed_configurations.map { |failed_configuration| failed_configuration.name }.to_sentence)
      post_fail_image(msg)
      false
    end
    
    return tc_was_green
  end
  
  def post_fail_image(msg)
    Thread.new do
      CampfireBot::Plugin.registered_plugins['Fail'].try(:fail, msg)
    end
  end
  
  protected
  
  def projects
    @projects ||= (
      builds = feed.entries.inject([]) { |array, entry| array << TeamCity::Build.from_feed_entry(entry) }.sort_by { |build| [build.build_number, build.configuration_name] }
      builds = builds.group_by { |build| build.project_name }
      builds.each do |project_name, project_builds|
        project_builds = project_builds.group_by { |project_build| project_build.configuration_name }
        project_builds.each { |configuration_name, configuration_builds| project_builds[configuration_name] = configuration_builds.sort_by(&:build_number) }
        builds[project_name] = project_builds
      end
    )
  end
  
  def team_city
    @team_city ||= TeamCity::ProjectManager.new.tap do |team_city|
      feed.entries.each do |entry| 
        build = TeamCity::Build.from_feed_entry(entry)
        team_city.add_build(build) unless config['ignored_configurations'].any? { |e| e == build.configuration_name}
      end
    end
  end

  def feed
    @feed ||= FeedNormalizer::FeedNormalizer.parse(open(config['url'], :http_basic_authentication=>[config['username'], config['password']]))
  end
  
  def refresh
    @projects = nil
    @feed = nil
  end
  
  def deploy_branch
    return config['deploy_branch']
  end
  
  def deploy_project
    return team_city.project(deploy_branch)
  end
end
