class SoundsNotRequired < CampfireBot::Plugin
  
  SOUNDS = %w[secret	trombone	crickets	rimshot	vuvuzela	tmyk	live	drama	yeah	greatjob	pushit	nyan	tada]
  
  on_message Regexp.new(SOUNDS.join("|")), :silent_sound
  
  def silent_sound(message)
    if message[:type] == 'SoundMessage' and 
       message[:room].name == 'BookRenter w/ Sounds'
      bot.rooms['BookRenter'].try(:speak, ":mega: #{message[:message]} is playing in BookRenter w/ Sounds")
    end
  end
  
end