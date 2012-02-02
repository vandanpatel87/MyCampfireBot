#Will calculate according to the commands given

class Calculate < CampfireBot::Plugin
	
  on_command "add", :add_nums
  on_command "sub", :sub_nums
  on_command "mul", :mul_nums
  on_command "div", :div_nums
  on_command "per", :per_nums
  on_command "tobin", :bin_nums
  on_command "todec", :dec_nums
    
    #calculate sum
    def add_nums(msg)
        numarr = msg[:message].squeeze(' ')
        numarr = numarr.split(' ').map(&:to_f)
        len = numarr.length
        total = 0
        for i in 0...len
            total = total + numarr[i]
        end    
        out = total.to_s
        msg.speak(out)
    end
    
    #calculate difference
    def sub_nums(msg)
        numarr = msg[:message].squeeze(' ')
        numarr = numarr.split(' ').map(&:to_f)
        if numarr.length > 1
            total = numarr[0] - numarr[1]
        else
            msg.speak("Give 2 arguments")
        end
        out = total.to_s
        msg.speak(out)
    end
    
    #calculate product
    def mul_nums(msg)
        numarr = msg[:message].squeeze(' ')
        numarr = numarr.split(' ').map(&:to_f)
        len = numarr.length
        total = 1
        for i in 0...len
            total = total * numarr[i]
        end    
        out = total.to_s
        msg.speak(out)
    end
    
    #calculate quotient
    def div_nums(msg)
        numarr = msg[:message].squeeze(' ')
        numarr = numarr.split(' ').map(&:to_f)
        if numarr[1] == 0
            msg.speak("Can't divide by 0")
        else
            if numarr.length > 1
                total = numarr[0] / numarr[1]
            else
                msg.speak("Give 2 arguments")
            end
        end
        out1 = total.to_s
        msg.speak(out1)
    end
    
    #calculate percentage
    def per_nums(msg)
        numarr = msg[:message].squeeze(' ')
        numarr = numarr.split(' ').map(&:to_f)
        if numarr[1] == 0
            msg.speak("Can't divide by 0")
            else
            if numarr.length > 1
                 total = (numarr[0] / numarr[1]) * 100.0   
            else
                msg.speak("Give 2 arguments")
            end
        end
        out1 = total.to_s
        msg.speak(out1 + " %")
    end
    
    #convert to binary function
    def bin_nums(msg)
        num = msg[:message].squeeze(' ').to_i
	if num == 0
		msg.speak("0")
	else
		numarr = Array.new
		while num > 0 do
			rem = num%2
			num = num/2
			numarr << rem
		end
		numarr.reverse!	
        	out1 = numarr.to_s
        	msg.speak(out1)
	end
    end
 
    #convert to decimal function
    def dec_nums(msg)
        numarr = msg[:message].squeeze(' ')
        numarr = numarr.split('').map(&:to_i)
        len = numarr.length
        total = 0
        for i in 0...len
            total = total + (2**i) * (numarr[len-i-1])
        end
        out = total.to_s
        msg.speak(out)
    end
end
