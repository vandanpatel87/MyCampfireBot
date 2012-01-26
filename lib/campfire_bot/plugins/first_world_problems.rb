require 'open-uri'
require 'nokogiri'

class FirstWorldProblems < CampfireBot::Plugin
  URL = 'http://www.reddit.com/r/firstworldproblems'
  at_interval 20.minutes, :timed_complain
  on_command "what's wrong", :complain

  def initialize
    @log = Logging.logger["CampfireBot::Plugin::FirstWorldProblems"]
    @title_nodes = nil
  end
  
  def timed_complain(msg)
    complain(msg) if timed_complain?
  end
  
  def complain(msg)
    msg.speak(random_complaint) 
  end

  private
  
  def timed_complain?
    (Time.now.hour > 8 and Time.now.hour < 22 and Time.now.wday != 6 and rand(28) < 1)
  end

  def complaints
    complaints = []
    complaints += complaints_from_url(URL)
    complaints += complaints_from_url(url_for_next_page)
    complaints += complaints_from_url(url_for_next_page)
  end
  
  def url_for_next_page
    last_story_id = @title_nodes.last.attr(:href).match(/.*\/(.*)\/.*?\//).try(:[], 1)
    "#{URL}?after=#{last_story_id}"
  end
  
  def complaints_from_url(url)
    @title_nodes = Nokogiri::HTML(open(url)).css('.entry a.title')
    @title_nodes.map(&:text)
  end
  
  def random_complaint
    complaints.sample
  end  
end