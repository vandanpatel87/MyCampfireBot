require 'open-uri'
require 'nokogiri'

class Rolodex < CampfireBot::Plugin
  on_command "my contact is", :save_employee
  on_command "find contact for", :find_employee
  
  def initialize
    @log = Logging.logger["CampfireBot::Plugin::Rolodex"]
  end
  
  def save_employee(msg)
    employee = Employee.find_by_username(msg['person']) || Employee.new(:username => msg['person'])
    employee.name = msg['user']['name'] if employee.name.blank?
    employee.email = msg['user']['email_address'] if employee.email.blank?
    
    begin
      employee.attributes = message_to_options(msg['message'])
      if employee.save
        msg.speak("Thanks! I just updated the information for #{employee.name}")
      else
        msg.speak("Nice try, but I had some problems.")
        employee.errors.full_messages.each do |error|
          msg.speak(error)
        end 
      end
    rescue ActiveRecord::UnknownAttributeError => e
      msg.speak("Nice try, but I had a problem: #{e.message}")
    end
  end
  
  def find_employee(msg)
    employees = Employee.where("name like ?", "%#{msg['message']}%")
    if employees.blank?
      msg.speak("Whoa there! That person doesn't exist.")
    else
      employees.each do |employee|
        msg.paste(employee.to_s)
      end
    end
  end
  
  private  
  
  def message_to_options(message)
    message.split(',').inject({}) {|acc, e| key, val = e.split(':'); acc[key.strip.parameterize.underscore] = val.strip; acc}
  end
end