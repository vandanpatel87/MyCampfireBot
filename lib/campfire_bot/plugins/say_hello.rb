class SayHello < CampfireBot::Plugin
    on_command 'say hello to', :hello
    on_command 'repeat', :repeat
    on_command 'add', :add
    on_command 'date', :date

    
    def hello(msg)
    out = "Hello ! #{msg[:message]}, Have a nice day !"
    my_length = length("#{msg[:message]}".split(" "))
    msg.speak(out + " There are #{my_length} arguments !")
    end
    
    def length(array)
        array.length
    end
    
    def repeat(msg)
       out = "#{msg[:message]} " * 2
       msg.speak(out) 
    end
    
    def add(msg)
        sum = 0
        out = "#{msg[:message]}".split(" ")
        
        out.each do |number|
            sum = sum + Integer(number)
            end 
        msg.speak(sum.to_s)
    end
    
    def date(msg)
        time = Time.new
        out = time.inspect.split(" ")
        msg.speak(out[1] + " " + out[2] + "," + " " + out[5])
    end 
end 