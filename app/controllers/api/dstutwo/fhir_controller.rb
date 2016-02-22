require 'json'
require 'postgres_calls'
require 'fhir_clojure_client'
#require 'faker'
require 'coderay'

class Api::Dstutwo::FhirController < ApplicationController
  include PostgresCalls 
  #protect_from_forgery with: :null_session
  #before_action :destroy_session

  before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, HEAD, POST, PUT, DELETE, TRACE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'origin, authorization, accept, content-type, x-requested-with'
    headers['Access-Control-Max-Age'] = "1728000"
    headers['Access-Control-Allow-Credentials'] = "true"
  end

  def cors_preflight_check
    if request.method == 'OPTIONS'
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'GET, HEAD, POST, PUT, DELETE, TRACE, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'origin, authorization, accept, content-type, x-requested-with'
      headers['Access-Control-Max-Age'] = '1728000'
      headers['Access-Control-Allow-Credentials'] = "true"

      render :text => '', :content_type => 'text/plain'
    end
  end     
  
  def example_read
  	@fhirCall = "https://sheltered-headland-5396.herokuapp.com/Patient/2d6ebe1f-6810-4b50-8b85-085d4ac6c0b2"
  	json_str = pg_call("SELECT fhir.read('Patient', '2d6ebe1f-6810-4b50-8b85-085d4ac6c0b2');")
  	@fhirResponseBody =  CodeRay.scan(JSON.pretty_generate(parse_json(json_str)) , :json).div
  	render :file => "/app/views/layouts/fhir_response.html.erb"
  end
  helper_method :example_read

  def example_create
  	@fhirCall = "https://sheltered-headland-5396.herokuapp.com/Patient"
  	puts params[:payload]
  	json_str = pg_call("SELECT fhir.create('#{params[:payload]}');")
  	@fhirResponseBody =  CodeRay.scan(JSON.pretty_generate(parse_json(json_str)) , :json).div
  	render :file => "/app/views/layouts/fhir_response.html.erb"
  end
  helper_method :example_create

  def example_search
  	@fhirCall = "https://sheltered-headland-5396.herokuapp.com/Patient?given=holly"
  	json_str = pg_call("SELECT fhir.search('Patient', 'family=skyes');")
  	@fhirResponseBody =  CodeRay.scan(JSON.pretty_generate(parse_json(json_str)) , :json).div
  	render :file => "/app/views/layouts/fhir_response.html.erb"
  end
  helper_method :example_search

  def caching_allowed? # Can't set ETag with the caching?
    false
  end
  
  def about
    render file: "/app/views/layouts/about.html.erb"
  end
  
  def contact
    render file: "/app/views/layouts/contact.html.erb"
  end

  def splashpage
   	#random_first_name = Faker::Name.first_name
  	#random_last_name = Faker::Name.last_name
  	@example_patient = "{\"resourceType\":\"Patient\", \"name\": [{\"given\": [\"#{random_first_name}\"],\"family\": [\"#{random_last_name}\"]}]}"
  	json_hash = JSON.parse(@example_patient)
  	@example_patient_pretty = CodeRay.scan(JSON.pretty_generate(json_hash) , :json).div
    render file: "/app/views/layouts/application.html.erb"
	#render html: '<h1>Fhir widget one experimental fhir server -- <a href="mailto:brianscott0017@yahoo.com" onmouseover="this.href=this.href.replace(/x/g,'');">contact</a></h1>'.html_safe
  end

  def is_request_format_xml
    result = true
	if request.headers.key?("Accept") then
	  if (request.headers["Accept"].include? "application/xml+fhir") then
	    result = true
	  elsif (request.headers["Accept"].include? "application/json+fhir") then
	    result = false
	  end
	end
	
	if params[:_format].present? then # _format param overrides accept header if present
      case params[:_format]
      when "xml", "text/xml", "application/xml", "application/xml+fhir"
        result = true
      when "json", "application/json", "application/json+fhir"
        result = false
	  else
        result = true	    
      end	
	end
	
	if request.headers.key?("Content-Type") then # content-type overrides format param	
      puts request.headers["Content-Type"].class.name
	  if (request.headers["Content-Type"].to_s.include? "application/json+fhir") then result = false end
	end
	
	return result	
  end

  def set_headers(resource_json_hash) # Parse the last-modified and others from the res in the db
    if resource_json_hash.key?("meta") then
	  headers['ETag'] = resource_json_hash["meta"]["versionId"]
	  headers['Last-Modified'] = resource_json_hash["meta"]["lastUpdated"]
	end    
  end
  
  def set_content_type_header()
    if is_request_format_xml then 
	  headers['Content-Type'] = 'application/xml+fhir;charset=UTF-8'
    else
	  headers['Content-Type'] = 'application/json+fhir;charset=UTF-8'
	end	
  end

  def is_id_valid_chars_and_length(id) # resource id's must abide by fhir spec rules for id's
	return (id =~ /^[A-Za-z0-9\-\.]{1,64}$/)
  end
  
  def convert_resource(resource_string)
	if is_request_format_xml then
      return ::FhirClojureClient.convert_to_xml(resource_string) # conv the json to xml using clojure lib
    else
	  return resource_string # res string already in json format requested, nothing to do
	end
	
  end
  
  def is_resource_exist(resource_type, id)
    return pg_call("SELECT fhir.is_exists('#{resource_type}', '#{id}');")
  end

  def get_err_status(outcome_json_hash) # Get error code from OperationOutcome json returned by fhirbase
    err_codes = ['400', '404', '410']
	err = nil
	outcome_json_hash['issue'][0]['code']['coding'].each do |element|
	  if err_codes.include? element['code'] then 
	    err = element['code']
	  end
	end
	
    if ! err.empty? then 
	  return err.to_i
	else
	  return 400
    end
	
  end

  def parse_json(str)
    begin
      result = JSON.parse(str)  
    rescue JSON::ParserError => e  
      result = e
    end 
	return result
  end
  
  def conformance
    resource_string = pg_call("SELECT fhir.read('Conformance', 'fb5ef8ec-55da-4718-9fd4-5a4c930ee8c9');") # hard coded conf record in db for now
	resource_json_hash = parse_json(resource_string)
	if resource_json_hash.is_a?(Hash) then
	  if resource_json_hash["resourceType"] == "OperationOutcome" then 
	    response_status = get_err_status(resource_json_hash)
	  else
	    response_status = 200
		set_headers(resource_json_hash)
	  end
	end   
	set_content_type_header()
    if defined?(resource_string) then body = convert_resource(resource_string) else body = '' end
	render :text => body, :status => response_status	
  end
  
  def read
	if ! is_id_valid_chars_and_length(params[:id]) then 
	  response_status = 400
	else
      resource_string = pg_call("SELECT fhir.read('#{params[:resource_type]}', '#{params[:id]}');")
	  resource_json_hash = parse_json(resource_string)
	  if resource_json_hash.is_a?(Hash) then
	    if resource_json_hash["resourceType"] == "OperationOutcome" then 
	      response_status = get_err_status(resource_json_hash)
	    else
	      response_status = 200
		  set_headers(resource_json_hash)
	    end
	  end
	end    
	set_content_type_header()
    if defined?(resource_string) then body = convert_resource(resource_string) else body = '' end
	render :text => body, :status => response_status  
  end

  # POST /api/{plural_resource_name}
  def create
    if is_request_format_xml then
      payload = ::FhirClojureClient.convert_to_json(request.body.read) # request.body.read --> xml body from request
    else
      payload = request.body.read # json
    end
    resource_string = pg_call("SELECT fhir.create('#{convert_resource(payload)}');")
	resource_json_hash = parse_json(resource_string)
	if resource_json_hash.is_a?(Hash) then
	  if resource_json_hash["resourceType"] == "OperationOutcome" then 
	    response_status = get_err_status(resource_json_hash)
	  else
	    response_status = 201
		set_headers(resource_json_hash)
	  end
	end
	set_content_type_header()
    if defined?(resource_string) then body = convert_resource(resource_string) else body = '' end
	render :text => body, :status => response_status
  end
 
  #  DELETE [base]/[type]/[id]
  def delete
    resource_string = pg_call("SELECT fhir.delete('#{params[:resource_type]}', '#{params[:id]}');")
	resource_json_hash = parse_json(resource_string)
	if resource_json_hash.is_a?(Hash) then
	  if resource_json_hash["resourceType"] == "OperationOutcome" then 
	    response_status = get_err_status(resource_json_hash)
	  else
	    response_status = 204
		set_headers(resource_json_hash)
	  end
	end
    
	set_content_type_header()
    if defined?(resource_string) then body = convert_resource(resource_string) else body = '' end
	render :text => body, :status => response_status
  end

  # Getting the search params out of the URL key-value pairs and then putting them into a string that fhirbase can use to search
  def get_search_string
	query_strings = request.query_parameters.to_hash()
	@search_string = ""
	query_strings.each do |key,value|
		puts "#{key.to_s}---#{value.to_s}"
		if @search_string.empty? then
			@search_string = "#{key.to_s}=#{value.to_s}"
		else
			@search_string.concat "&#{key.to_s}=#{value.to_s}"
		end
	end
	return @search_string
  end
  
  def search
    resource_string = pg_call("SELECT fhir.search('#{params[:resource_type]}', '#{get_search_string}');")
	resource_json_hash = parse_json(resource_string)
	if resource_json_hash.is_a?(Hash) then
	  if resource_json_hash["resourceType"] == "OperationOutcome" then 
	    response_status = get_err_status(resource_json_hash)
	  else
	    response_status = 200
		set_headers(resource_json_hash)
	  end
	end
    
	set_content_type_header()
    if defined?(resource_string) then body = convert_resource(resource_string) else body = '' end
	render :text => body, :status => response_status	
  end
  
  # PATCH/PUT /api/{resource_name}/id
  def update
    if is_request_format_xml then
      payload = ::FhirClojureClient.convert_to_json(request.body.read) # request.body.read --> xml body from request
    else
      payload = request.body.read # json
    end
    resource_string = pg_call("SELECT fhir.update(fhirbase_json.merge(fhir.read('#{params[:resource_type]}', '#{params[:id]}'),'#{payload}'));")
	resource_json_hash = parse_json(resource_string)
	if resource_json_hash.is_a?(Hash) then
	  if resource_json_hash["resourceType"] == "OperationOutcome" then 
	    response_status = get_err_status(resource_json_hash)
	  else
	    response_status = 200
		set_headers(resource_json_hash)
	  end
	end
	set_content_type_header()
    if defined?(resource_string) then body = convert_resource(resource_string) else body = '' end
	render :text => body, :status => response_status
  end 
  
  def vread
	if ! is_id_valid_chars_and_length(params[:vid]) then 
	  response_status = 400
	else
      resource_string = pg_call("SELECT fhir.vread('#{params[:resource_type]}', /*old_version_id*/ '#{params[:vid]}');")
	  resource_json_hash = parse_json(resource_string)
	  if resource_json_hash.is_a?(Hash) then
	    if resource_json_hash["resourceType"] == "OperationOutcome" then 
	      response_status = get_err_status(resource_json_hash)
	    else
	      response_status = 200
		  set_headers(resource_json_hash)
	    end
	  end
	end    
	set_content_type_header()
    if defined?(resource_string) then body = convert_resource(resource_string) else body = '' end
	render :text => body, :status => response_status  
  end
  
  def history
    resource_string = pg_call("SELECT fhir.history('#{params[:resource_type]}', '#{params[:id]}');")
	resource_json_hash = parse_json(resource_string)
	if resource_json_hash.is_a?(Hash) then
	  if resource_json_hash["resourceType"] == "OperationOutcome" then 
	    response_status = get_err_status(resource_json_hash)
	  else
	    response_status = 200
		set_headers(resource_json_hash)
	  end
	end
    
	set_content_type_header()
    if defined?(resource_string) then body = convert_resource(resource_string) else body = '' end
	render :text => body, :status => response_status
  end

  def destroy_session
    request.session_options[:skip] = true
  end

  def request_params
    params.permit(:resource_type, :id)
  end
  
  private
  
end
