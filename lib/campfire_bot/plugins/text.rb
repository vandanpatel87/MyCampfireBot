require 'rubygems'
require 'twilio-ruby'

class Text < CampfireBot::Plugin
  on_command 'text', :text_method
  
  def text_method(msg)
    
    out = "#{msg[:message]}".split(" ")
    
    number = out.shift
    msg.speak("Destination Number : " + number)
    
    message = out.join(" ")
    msg.speak("Message Sent: " + message)
    
    account_sid = 'ACd2900b750a9343ff4348feae326a8ff7'
    auth_token = 'adce9bd993361bae6b40647d918c8e72'
    
    @client = Twilio::REST::Client.new(account_sid, auth_token)
   
    @client.account.sms.messages.create(
      :from => '+16504926856',
      :to => '+1' + number,
      :body => message + "\r\n" + "BookRenter.com"
    )
 
  end 
end
