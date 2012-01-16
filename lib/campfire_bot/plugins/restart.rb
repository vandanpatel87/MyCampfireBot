class Restart < CampfireBot::Plugin
  on_command 'restart yourself', :restart_reg
  
  def restart_reg(msg)
    msg.speak("Restarted")
    cmd = "cd /var/www/reg/current/script && bundle exec ./bot_daemon.rb restart -- #{Rails.env}"
    @log.info(cmd)
    
    output = `#{cmd}`
  end
  
  def initialize
    @log = Logging.logger["CampfireBot::Plugin::Restart"]
  end
  
end