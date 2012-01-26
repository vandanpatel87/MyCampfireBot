require 'open-uri'
require 'hpricot'
require 'tempfile'

class Fail < CampfireBot::Plugin
  on_command 'fail', :fail
  
  def fail(msg)
    msg.speak(self.random_fail)
  rescue => e
    msg.speak e
  end
  
  def random_fail
    (Hpricot(open('http://failblog.org/?random#top'))/'div.entry img').first['src']
  end
end