class Selenium < CampfireBot::Plugin
  on_command 'selenium', :selenium_link
  
  def selenium_link(msg)
    msg.speak("http://www.devqa.stg.bookrenter.com/TestResults.html")
  end
  
  def initialize
    @log = Logging.logger["CampfireBot::Plugin::Selenium"]
  end
end