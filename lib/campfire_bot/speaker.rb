module CampfireBot
  class Message < ActiveSupport::HashWithIndifferentAccess
    
    def speak_with_thundergun(str)
      lname = 'p' + 'e' + 'a' + 'r' + 'c' + 'e'
      rname = 'P' + 'e' + 'r' + 'v' + 'y'
      str.gsub!(/#{lname}/i, rname) unless str =~/\bhttp/
      speak_without_thundergun(str)
    end
    alias_method_chain :speak, :thundergun
    
  end
end
