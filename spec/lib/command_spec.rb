require 'spec'

BOT_ENVIRONMENT = 'test'
require 'campfire_bot/bot.rb'
bot = CampfireBot::Bot.instance


class TestingCommand < CampfireBot::Event::Command

  def filter_message(msg)
    super
  end
end

describe "processing messages" do
  
  before(:all) do
    bot = CampfireBot::Bot.instance
    @nickname = bot.config['nickname']
  end
  
  before(:each) do
    @command = TestingCommand.new("command", nil, nil)
  end  
    
  def match?(msg)
    @command.match?({:message => msg})
  end
  
  describe "and recognizing a command" do
    
    it "should handle a !command" do
      match?("!command").should be_true
    end
  
    it "should handle a !command with arguments" do
      match?("!command foo").should be_true
    end
  
    it "should handle a command with nickname and a comma" do
      match?("#{@nickname}, command").should be_true
    end
  
    it "should handle a command with nickname and a colon" do
      match?("#{@nickname}: command").should be_true
    end
  
    it "should handle a command with nickname and no delimiter" do
      match?("#{@nickname} command foo").should be_true
    end
    
    it "should handle a multi-word command with nickname and no delimiter" do
      @command = TestingCommand.new("do a command", nil, nil)
      match?("#{@nickname} do a command foo").should be_true
    end
  
    it "should handle a command with nickname and arguments" do
      match?("#{@nickname}, command foo").should be_true
    end
      
    it "should ignore a non-matching !command" do
      match?("!foo").should be_false
    end
  
    it "should ignore an addressed non-command" do
      match?("#{@nickname}, nothing").should be_false
    end
  
    it "should ignore things that aren't commands at all" do
      ["nothing", "#{@nickname}, ", " ! command", "hey #{@nickname}"].each do |t|
        match?(t).should be_false
      end
    end
  end
  
  describe "and filtering it" do
    
    def filter(msg)
      @command.filter_message({:message => msg})[:message]
    end

    it "should be empty with no arguments" do
      filter("!command").should == ""
      filter("#{@nickname}, command").should == ""
    end
    
    it "should return one argument" do
      filter("!command foo").should == "foo"
      filter("#{@nickname}, command foo").should == "foo"      
    end
    
    it "should return more than one argument" do
      filter("!command foo bar baz").should == "foo bar baz"
      filter("#{@nickname}, command foo bar baz").should == "foo bar baz"
    end
    
    it "should deal with some weirdness" do
      filter("!command !command").should == "!command"
    end
    
    describe "when command is multi-word" do
      before(:each) do
        @command = TestingCommand.new("do a command", nil, nil)
      end
      
      it "should be empty with no arguments" do
        filter("!do a command").should == ""
        filter("#{@nickname}, do a command").should == ""
      end

      it "should return one argument" do
        filter("!do a command foo").should == "foo"
        filter("#{@nickname}, do a command foo").should == "foo"      
      end

      it "should return one argument when command has no delimiter" do
        filter("#{@nickname} do a command foo").should == "foo"      
      end

      it "should return more than one argument" do
        filter("!do a command foo bar baz").should == "foo bar baz"
        filter("#{@nickname}, do a command foo bar baz").should == "foo bar baz"
      end
      
      it "should return more than one argument when command has no delimiter" do
        filter("#{@nickname} do a command foo bar baz").should == "foo bar baz"
      end
    end
  end  
end

