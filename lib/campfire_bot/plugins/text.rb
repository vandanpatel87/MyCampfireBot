require 'rubygems'
require 'twilio-ruby'


class Text < CampfireBot::Plugin
  on_command 'text', :text_method
  
  def text_method(msg)
    
    out = "#{msg[:message]}".split(" ")
    
    number = out.shift
    msg.speak("Destination Number : " + number)
    
    myString = out.join(" ")
    msg.speak("Message to be sent : " + myString)
    
    array = myString.split(//)
    
    begin
      deliver_message(array.slice!(0...160).to_s,number)
    end while (out.size > 0)
    
  end
  
 def deliver_message(sms_body,number)
   
    account_sid = 'ACd2900b750a9343ff4348feae326a8ff7'
    auth_token = 'adce9bd993361bae6b40647d918c8e72'
    
    @client = Twilio::REST::Client.new(account_sid, auth_token)
   
    @client.account.sms.messages.create(
      :from => '+16504926856',
      :to => '+1' + number,
      :body => sms_body 
    )  
    
  end
end
 
