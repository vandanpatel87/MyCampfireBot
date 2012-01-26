class MagicEightBall < CampfireBot::Plugin
  ANSWERS = ['It is certain', 'It is decidedly so', 'Without a doubt', 'Yes – definitely', 'You may rely on it',
             'As I see it, yes', 'Most likely', 'Outlook good', 'Signs point to yes', 'Yes', 'Reply hazy, try again',
             'Ask again later', 'Better not tell you now', 'Cannot predict now', 'Concentrate and ask again',
             'Don\'t count on it', 'My reply is no', 'My sources say no', 'Outlook not so good', 'Very doubtful']
  
  on_command 'will', :shake_and_flip
  on_command 'should', :shake_and_flip
  on_command 'does', :shake_and_flip
  on_command 'can', :shake_and_flip
  on_command 'is', :shake_and_flip
  on_command 'are', :shake_and_flip
  on_command 'did', :shake_and_flip
  on_command 'do', :shake_and_flip
  
  def initialize
    @log = Logging.logger["CampfireBot::Plugin::MagicEightBall"]
  end
  
  def shake_and_flip(msg)
    msg.speak(ANSWERS.sample)
  end
end