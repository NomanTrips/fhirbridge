class ApplicationController < ActionController::API
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception

before_filter :add_allow_credentials_headers

def add_allow_credentials_headers                                                                                                                                                                                                                                                        
  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS#section_5                                                                                                                                                                                                      
  #                                                                                                                                                                                                                                                                                       
  # Because we want our front-end to send cookies to allow the API to be authenticated                                                                                                                                                                                                   
  # (using 'withCredentials' in the XMLHttpRequest), we need to add some headers so                                                                                                                                                                                                      
  # the browser will not reject the response                                                                                                                                                                                                                                             
  headers['Access-Control-Allow-Origin'] = '*'
  headers['Access-Control-Allow-Methods'] = 'GET, HEAD, POST, PUT, DELETE, TRACE, OPTIONS'
  headers['Access-Control-Allow-Headers'] = 'origin, authorization, accept, content-type, x-requested-with'
  headers['Access-Control-Max-Age'] = "1728000"
  headers['Access-Control-Allow-Credentials'] = "true" 
  puts 'running add allow cred headers....'                                                                                                                                                                                                                    
end 

def options                                                                                                                                                                                                                                                                              
  head :status => 200, :'Access-Control-Allow-Headers' => 'accept, content-type'                                                                                                                                                                                                         
end
  
end
