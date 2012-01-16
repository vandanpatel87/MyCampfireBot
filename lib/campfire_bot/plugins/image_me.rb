require 'googleajax'
require 'tempfile'

class ImageMe < CampfireBot::Plugin
  BASE_URL = 'http://images.google.com/images'
  
  on_command 'fetch me', :random_image
  on_command 'image me', :random_image
  on_command 'bieber me', :random_bieber_image
  
  def initialize
    @log = Logging.logger["CampfireBot::Plugin::ImageMe"]
  end
  
  def random_bieber_image(msg)
    msg.speak(random_url('justin bieber'))
  end

  def random_image(msg)    
    msg.speak(random_url(msg[:message]))
  end
  
  private

  def fetch_image_urls(term)
    GoogleAjax.referrer = 'http://www.bookrenter.com'
    return GoogleAjax::Search.images(term, :start => rand(7))[:results].map { |e| e[:unescaped_url] }
  end
  
  def random_url(term)
    image_urls = fetch_image_urls(term)
    @log.info image_urls.inspect
    return image_urls[rand(image_urls.size)]
  end  
end