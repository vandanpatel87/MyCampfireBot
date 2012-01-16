class TeamCitySimple < CampfireBot::Plugin
  at_interval 10.minutes, :check_tc
  on_command "tc", :check_tc
  
  PROJECTS=["dev","master"]
  STATES=[:good,:bad,:ack]

  def initialize
    @log = Logging.logger["CampfireBot::Plugin::TeamCitySimple"]
    @state=:good
  end
  
  def check_tc(msg)
    explicit_status = (msg[:message] =~ /status/)
    all_good = true
    
    PROJECTS.each do |project_name|
      is_green = TeamCity::Project.find_by_name(project_name).green?
      if !is_green
        msg.speak "The latest build of #{project_name} project is currently RED!" if @state == :bad or explicit_status
        all_good = false
        @state = :bad if @state == :good
      end
    end
    
    if msg[:message] =~ /status/
      msg.speak "Internal reg TC state is currently: #{@state}"
    end

    if msg[:message] =~ /ack/
      @state=:ack
      msg.speak "Broken build acknowledged by #{msg[:person]}.  I will remain silent until the status improves."
    end
    
    if all_good and (@state == :ack or @state == :bad)
      @state = :good
      msg.speak "All builds on all watched projects (#{PROJECTS}) are now green."
    end
  end
end