class Compliment < CampfireBot::Plugin
  
  on_command 'compliment', :compliment
  
  def compliment(msg)
    adj1 = adjective()
    adj2 = adjective()
    adj3  = adjective()
    adv1 = adverb()
    adv2 = adverb()
    adv3 = adverb()
    noun = noun()
    
    article = "a"
    article = "an" if (noun[0] =~ /^[aeiou]/)    
    out = ["#{msg[:message]}, you are the most #{adv1} #{adj1} #{noun} I have #{known}.",
           "I shall never meet #{article} #{noun} so #{adv1} #{adj1} as you, dear #{msg[:message]}.",
           "I will never forget you, dear #{msg[:message]}.",
           "#{msg[:message]}, you are #{adv1} #{adj1}, #{adv2} #{adj2} and always #{adv3} #{adj3}.",
           "#{msg[:message]}, you are a true #{noun}.",
           "#{msg[:message]}, were you any more #{adj1}, I should want to #{verb}.",
           "#{msg[:message]}, I must admit I find you quite #{adj1}.",
           "If you aren't #{adj1}, #{msg[:message]}, I don't know what you are.",
           "#{msg[:message]}, you are half the man Philippe Huibonhoa is."
          ]
    out = out[rand(out.size)]
    msg.speak(out)
  end
  
  private
  
  def adverb()
    adverbs = %w(wonderously alluringly appealingly 
    attractively bewitchingly celestially charmingly delightfully divinely elegantly 
    entrancingly excellently exquisitely gorgeously gracefully handsomely ideally magnificently 
    prettily seductively splendidly sublimely superbly tastefully wonderfully awfully drastically exceedingly exceptionally excessively 
    exorbitantly extraordinarily highly hugely immensely immoderately inordinately intensely markedly mortally notably
    prohibitively remarkably severely strikingly surpassingly terribly terrifically too uncommonly unduly unusually utterly violently vitally
    )
    
    adverbs[rand(adverbs.size)]
    
  end
  
  def adjective()
    adjectives = %w(admirable amazing astonishing astounding awe-inspiring awesome brilliant cool
     divine enjoyable excellent fabulous fantastic groovy incredible magnificent marvelous miraculous outstanding peachy phenomenal 
     pleasant pleasing prime remarkable sensational staggering startling strange stupendous superb surprising swell terrific tremendous wondrous unique
     arousing inviting kissable provocative seductive sensual sensuous spicy suggestive titillating voluptuous ambrosial appealing attractive captivating 
     charming darling delectable delicious delightful dishy dreamy fetching heavenly luscious precious    
    )
     
    adjectives[rand(adjectives.size)]
  end
  
  def known()
    phrases = %w(known had|the|pleasure|of|meeting met seen|in|person witnessed imagined counted|among|my|friends)
    
    phrases[rand(phrases.size)].gsub("|", " ")
  end
  
  def noun()
    nouns = %w(gentleperson genius conversationalist intellect marvel miracle phenomenon rarity talent wonder wunderkind individual personage soul spirit prodigy dear)
    
    nouns[rand(nouns.size)]
  end

  def verb()
    verbs = %w(adopt|* kidnap|* run|away|with|* wed|*  make|off|with|* privately|entertain|* eat|*|up bring|*|into|my|family open|an|account|in|*r|name make|a|hobby|of|* take|a|picture|of|*)
    
    verbs[rand(verbs.size)].gsub("|", " ").gsub("*", "you")
    
  end

end


