# lib/oauth2_calls.rb
require 'json'
require 'http'

module Oauth2Calls

  def parse_json(str)
    begin
      result = JSON.parse(str)  
    rescue JSON::ParserError => e  
      result = e
    end 
	return result
  end

  def introspect_token(access_token)
  	client_id = "d952fe96-73de-4850-bf95-1d6c4e76b6f7"
  	client_secret = "ANgugQvcZLe3JXB9DblrMjkCue25enOmrRVgivtwYNsedmWWCIx9cIdiAU4R-weFkruYTpdjYPL4IQ5jHrKTST8"
    response = HTTP.basic_auth(:user => client_id, :pass => client_secret)
      .headers(:accept => "application/json")
      .post('https://arcane-meadow-94486.herokuapp.com/introspect', :params => {:token => access_token})
    puts "response status: #{response.code.to_s}"
    puts "resp body: #{response.to_s}"
    response_hash = parse_json(response.to_s)
    return response_hash['active']
  end
  
end