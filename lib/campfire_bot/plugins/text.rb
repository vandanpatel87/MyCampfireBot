require 'rubygems'
require 'twilio-ruby'
require 'twilio'


class Text < CampfireBot::Plugin
  on_command 'text', :text_method
   
  def text_method(msg)
    out = "#{msg[:message]}".split(" ")
    name = out.shift
    employees = Employee.where("name like ?", "%#{name}%")
    if employees.blank?
      msg.speak("Whoa there! That person doesn't exist.")
    else
      employees.each do |employee|
      myString = out.join(" ") + " -- #{msg['person']}"
      array = myString.split(//)   
    begin
        response = deliver_message(array.slice!(0...160).to_s,employee.mobile)
        response_number = response.response.code
        if(response_number =~ /^20\d$/)
          msg.speak("Message Sent")
        else 
          msg.speak(" Sorry ! Message is not sent ! Please Try again :)")
        end
     end while (array.size > 0)
   end
 end
end
  
 def deliver_message1(sms_body,number)
   
    account_sid = 'ACd2900b750a9343ff4348feae326a8ff7'
    auth_token = 'adce9bd993361bae6b40647d918c8e72'
    
    @client = Twilio::REST::Client.new(account_sid, auth_token)
   
    @client.account.sms.messages.create(
      :from => '+16504926856',
      :to => '+1' + number,
      :body => sms_body
    )
    
  end
  
  def deliver_message(sms_body,number)
    Twilio.connect('ACd2900b750a9343ff4348feae326a8ff7', 'adce9bd993361bae6b40647d918c8e72')
    Twilio::Sms.message("+16504926856",'+1' + number,sms_body)
  end
end
 


