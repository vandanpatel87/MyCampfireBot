require 'open-uri'
require 'hpricot'
require 'tempfile'

class Selleck < CampfireBot::Plugin
  on_command 'selleck', :selleck
  
  def initialize
    @log = Logging.logger["CampfireBot::Plugin::Selleck"]
  end
  
  def selleck(msg)
    selleck = (Hpricot(open('http://selleckwaterfallsandwich.tumblr.com/random'))/'div#content img').first['src']
    msg.speak(selleck)
  end
end