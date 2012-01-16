require 'uri'
require 'open-uri'
require 'active_support'
require 'zlib'
require 'nokogiri'

class DoYouKnow < CampfireBot::Plugin
  on_command 'do you know', :do_you_know_command
  
  def do_you_know_command(msg)
    do_you_know(msg[:message]).each do |statement|
      msg.html(statement)
    end
  end

private

  def fetch_json_hash(url, deflate = false)
    response = open(url)
    response = Zlib::GzipReader.new(response) if deflate
    return ActiveSupport::JSON.decode(response.read)
  end

  def dont_know_answer(question)
    message = (config['dont_know_responses'] || ["Sorry, I don't know the answer to that.  Try"]).shuffle.first
    return "#{message} #{googling_link(question)}."
  end

  def googling_link(question)
    "<a href='http://www.google.com/#q=#{URI.escape(question)}'>googling it</a>"
  end
  
  def do_you_know(question)
    statements = []
    begin
      search_result_url = fetch_question_url(question)
      if search_result_url
        question_id = search_result_url.sub(/^.*questions\//, '').sub(/\/.*$/, '')
        question_response = fetch_json_hash("http://api.stackoverflow.com/1.1/questions/#{question_id}?body=true", true)
        question_i_know = "I know this: #{question_response['questions'][0]['title']}"
        
        answer_response = fetch_json_hash("http://api.stackoverflow.com/1.1/questions/#{question_id}/answers?sort=votes&body=true&pagesize=1", true)
        has_accepted_answer = answer_response['answers'].detect {|a| a['accepted'] || a['up_vote_count'] > 3}
        if has_accepted_answer
          statements << question_i_know
          # take the most up voted, not the one chosen by question asker
          statements << answer_response['answers'][0]['body']
          statements << "Here's <a href='http://stackoverflow.com/questions/#{question_id}'>where I found the information</a>"
        end
      end
      if statements.empty?
        statements << dont_know_answer(question)
      end
    rescue Exception => e
      statements << "Sorry, my brain hurts. I think it has to do with #{e}: #{e.backtrace[0]}."
    end
  
    return statements
  end
  
  def fetch_question_url(question)
    doc = Nokogiri::HTML(open("http://stackoverflow.com/search?q=#{URI.escape(question)}"))
    path = doc.css('a.question-hyperlink').first['href']
    if path
      url = "http://stackoverflow.com" + path.gsub(/^.*?\/questions\//, '/questions/')
    end
    url
  end
end

# a_question = 'What is the most popular programming language?'
# a_question = 'How to install a plugin from github?'
# a_question = 'What is the best ruby editor for a mac?'
# a_question = 'the top companies in the bay area?'
# a_question = 'why activerecord has an error'
# a_question = 'best open source iphone libraries' # unordered list
# a_question = 'why won\'t foo make assignment' # code blocks
# msg = CampfireBot::Message.new(:message => a_question)
# def msg.paste(text); puts "-+--#{text}" end
# def msg.speak(text); puts "-+--#{text}" end
# DoYouKnow.new.do_you_know_command(msg)
# raise "EXIT"