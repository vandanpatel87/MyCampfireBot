require 'time'
require 'base64'

class SayWhats < CampfireBot::Plugin
  
  at_interval 30.seconds, :say_whats
  
  def initialize
    @e = "6+dRPH5G67VP8WxrVdgfvVtwx/sNosVb78KXgNxKmQ3/zwcyxAGPvIIf/lOm\nKKI7WhSCc6f3Lyeh+F/hgERcrq9BlNe5iPQvGiJpFkofkahKaY0qJu61Ko2c\nA1uvY26P\n"
    @latest = Time.now
  end
  
  def say_whats(msg)
    if reg_speak = fetch_new_reg_speak
      msg.speak(reg_speak[:words])
      @latest = reg_speak[:time]
    end
  end
  
  private
  
  def fetch_new_reg_speak
    eval(Base64.decode64("ICAgIHJlcXVpcmUgJ25va29naXJpJwogICAgcmVxdWlyZSAnaHR0cGFydHkn\nCiAgICByZXF1aXJlICdvcGVuc3NsJwogICAgcmVxdWlyZSAnZGlnZXN0L3No\nYTEnCiAgICAKICAgIGMgPSBPcGVuU1NMOjpDaXBoZXI6OkNpcGhlci5uZXco\nImFlcy0yNTYtY2JjIikKICAgIGMuZGVjcnlwdAogICAgYy5rZXkgPSBEaWdl\nc3Q6OlNIQTEuaGV4ZGlnZXN0KCJ5b3VycGFzcyIpCiAgICBjLml2ID0gQmFz\nZTY0LmRlY29kZTY0KCJ4L0RxM1hPR29DdWRROGlPaFpDOHpBPT0KIikKICAg\nIGQgPSBjLnVwZGF0ZShCYXNlNjQuZGVjb2RlNjQoQGUpKQogICAgZCA8PCBj\nLmZpbmFsCiAgICBkb2MgPSBOb2tvZ2lyaTo6WE1MKEhUVFBhcnR5LmdldChk\nKS5ib2R5KQogICAgaXRlbSA9IGRvYy5jc3MoJ2l0ZW0nKS5maXJzdAogICAg\naWYgaXRlbQogICAgICB0aW1lID0gVGltZS5wYXJzZShpdGVtLmNzcygncHVi\nRGF0ZScpLnRleHQpCiAgICAgIGlmIHRpbWUgPiBAbGF0ZXN0CiAgICAgICAg\ncmVnX3NwZWFrID0gewogICAgICAgICAgOndvcmRzID0+IGl0ZW0uY3NzKCdk\nZXNjcmlwdGlvbicpLnRleHQuZ3N1YigvXi4qPzogLywgJycpLAogICAgICAg\nICAgOnRpbWUgPT4gVGltZS5wYXJzZShpdGVtLmNzcygncHViRGF0ZScpLnRl\neHQpCiAgICAgICAgfQogICAgICBlbmQKICAgIGVuZAogICAgcmVnX3NwZWFr\nCg==\n"))
  end
end