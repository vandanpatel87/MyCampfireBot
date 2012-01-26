require File.join(File.dirname(__FILE__), %w[performance new_relic])

class PerformanceAlerts < CampfireBot::Plugin
  
  at_interval 1.hour, :daily_annoucement
  on_command 'slow pages', :say_performance_most_wanted
  
  def initialize
    @log = Logging.logger["CampfireBot::Plugin::PerformanceAlerts"]
  end
  
  def daily_annoucement(msg)
    say_performance_most_wanted(msg) if annoucement_time?
  end
  
  def say_performance_most_wanted(msg)
    nr = Performance::NewRelic.new
    slowest_transactions = nr.slow_transaction_chart
    
    msg.speak(":construction:  SLOWEST PERFORMING PAGES (by count x avg)  :construction:")
    msg.paste(slowest_transactions)
  end
  
  
  private
  
  def annoucement_time?
    Time.now.hour == 14
  end
end