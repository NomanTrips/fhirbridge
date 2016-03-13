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
  	client_id = "2a557ada-8fd7-4144-9e00-26375fb4b398"
  	client_secret = "AIiLQqa_yK-DTlrPNyjNAUEjM6F1WV2v7iwipOILtUc5_18c27kMlJZxXtfZ8Nai6LjjhDBI-GiwxuYZOWX_tpk"
    response = HTTP.basic_auth(:user => client_id, :pass => client_secret)
      .headers(:accept => "application/json")
      .post('https://arcane-meadow-94486.herokuapp.com/introspect', :params => {:token => access_token})
    puts "response status: #{response.code.to_s}"
    puts "resp body: #{response.to_s}"
    response_hash = parse_json(response.to_s)
    return response_hash['active']
  end
  
end