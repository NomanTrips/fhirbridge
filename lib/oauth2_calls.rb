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
  	client_id = "cbd84267-2982-4374-ae75-494b43e2c67c"
  	client_secret = "AMeF33i-olinor3QuUiYJO4B87Nsy3PsrVIbdlWKjHXj2WM01x4pZlThD6kFdofmeTZjp5P6R0gYJ__xYuqO8j0"
    response = HTTP.basic_auth(:user => client_id, :pass => client_secret)
      .headers(:accept => "application/json")
      .post('https://arcane-meadow-94486.herokuapp.com/introspect', :params => {:token => access_token})
    response_hash = parse_json(response.to_s)
    if response_hash.key?("active") then
      return response_hash['active'] # json response node from auth server, bool which tells if token is valid
    else
      return false
    end

  end
  
end