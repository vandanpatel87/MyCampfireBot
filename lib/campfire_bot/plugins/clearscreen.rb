require 'lipsum'

class ClearScreen < CampfireBot::Plugin
  on_command 'cls', :clear
  on_command 'clearscreen', :clear
  on_command 'clear', :clear

  def clear(msg)
    lipsum = Lipsum.new
    (1..5).each { msg.speak lipsum.paragraphs[3].to_s }
  end
end