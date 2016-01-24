require 'json'
require 'nokogiri'
require 'postgres_calls'
require 'fhir_clojure_client'

  
class Api::V1::BaseController < ApplicationController
  include PostgresCalls 
  #protect_from_forgery with: :null_session
  #before_action :destroy_session     
  
  def caching_allowed? # Can't set ETag with the caching?
    false
  end

  def splashpage
    render html: '<h1>Fhir widget one experimental fhir server -- <a href="mailto:brianscott0017@yahoo.com" onmouseover="this.href=this.href.replace(/x/g,'');">contact</a></h1>'.html_safe
  end

  def is_request_format_xml
    if (request.headers["Accept"] == 'application/json+fhir') ||
       (request.headers["Content-Type"] == 'application/json+fhir') then
      return false
	else
	  return true
	end
	
  end
  
  def build_headers(resource_json_hash)
    headers['Content-Type'] = 'application/xml+fhir' # default content type xml
	if request.headers.key?("Accept") then headers['Content-Type'] = request.headers["Accept"] end
    if request.headers.key?("Content-Type") then headers['Content-Type'] = request.headers["Content-Type"] end	
	if ! resource_json_hash.empty? then 
	  if resource_json_hash.key?("meta") then
	    headers['ETag'] = resource_json_hash["meta"]["versionId"]
		headers['Last-Modified'] = resource_json_hash["meta"]["lastUpdated"]
	  end
      
	end
	
  end

  def is_id_valid_chars_and_length(id)
	return (id =~ /^[A-Za-z0-9\-\.]{1,64}$/)
  end
  
  def conformance 
    resource_string = pg_call("SELECT fhir.read('Conformance', 'fb5ef8ec-55da-4718-9fd4-5a4c930ee8c9');") # hard coded conf record in db for now
    
	if is_request_format_xml then
	  resource_string = ::FhirClojureClient.convert_to_xml(resource_string)
    end	
			
	render text: resource_string, content_type: request.headers["Accept"]
  end
  
  def show
	if ! is_id_valid_chars_and_length(params[:id]) then
	  response_status = 400
	else	
	  does_res_exist = pg_call("SELECT fhir.is_exists('#{params[:resource_type]}', '#{params[:id]}');")
	  if ! does_res_exist then
	    response_status = 404
	  end	
    end
	
	if (does_res_exist) && ( is_id_valid_chars_and_length(params[:id]) ) then
      resource_string = pg_call("SELECT fhir.read('#{params[:resource_type]}', '#{params[:id]}');")
	else
	  resource_string = nil
	end
	
	if resource_string == "No table for that resourceType" then
	  response_status = 404 # Un-supported resource
	end

 	resource_json_hash = nil
	if ! resource_string.nil? then
	  resource_json_hash = JSON.parse resource_string   
	  if resource_json_hash["resourceType"] == "OperationOutcome" then # deleted resource
	    response_status = 410
      else # found resource and everything was ok
	    response_status = 200
	  end
    end
	
	build_headers(resource_json_hash)
	if (is_request_format_xml) && ( ! resource_string.nil? ) then
      resource_string = ::FhirClojureClient.convert_to_xml(resource_string)
    end
	render :text => resource_string, :status => response_status
	
  end

  # POST /api/{plural_resource_name}
  def create
	
    if is_request_format_xml then
      payload = ::FhirClojureClient.convert_to_json(request.body.read) # request.body.read --> xml body from request
    else
      payload = request.body.read # json
    end
	
    resource_string = pg_call("SELECT fhir.create('#{payload}');")

    if ! resource_string.empty? then
      if resource_string == "No table for that resourceType" then
        response_status = 404
      else
        resource_json_hash = JSON.parse resource_string
        if resource_json_hash["resourceType"] == "OperationOutcome" then #deleted resource
          response_status = 400
        else
          headers['ETag'] = resource_json_hash["meta"]["versionId"]
          headers['Location'] = request.original_url + "/#{resource_json_hash["id"]}"
		  headers['Content-Type'] = request.headers["Content-Type"]
          response_status = 201
        end
		
        if is_request_format_xml then
          resource_string = ::FhirClojureClient.convert_to_xml(resource_string)
        end
      
	  end
	  
    end
		
    render :text => resource_string, :status => response_status

  end
 
  #  DELETE [base]/[type]/[id]
  def delete
    	
    resource_string = pg_call("SELECT fhir.delete('#{params[:resource_type]}', '#{params[:id]}');")

    if ! resource_string.empty? then
      resource_json_hash = JSON.parse resource_string
      if resource_json_hash.key?("resourceType") then
        response_status = 204
        if resource_json_hash.key?("meta") then
          headers['ETag'] = resource_json_hash["meta"]["versionId"]
        end
		
        if is_request_format_xml then
          resource_string = ::FhirClojureClient.convert_to_xml(resource_string)
        end
		
      end
				
    end
		
    render :text => resource_string, :status => response_status
  end
  
  def search
	# Getting the search params out of the URL key-value pairs and then putting them into a string that fhirbase can use to search
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

	resource_string = pg_call("SELECT fhir.search('#{params[:resource_type]}', '#{@search_string}');")	
		
	if ! resource_string.empty? then
		if resource_string == "No table for that resourceType" then
			response_status = 404
		else
			resource_json_hash = JSON.parse resource_string
			if resource_json_hash["resourceType"] == "OperationOutcome" then #deleted resource
				response_status = 410
			else
				response_status = 200
			end
		
			if is_request_format_xml then
				resource_string = ::FhirClojureClient.convert_to_xml(resource_string)
			end
		end
	end
	
	render :text => resource_string, :status => response_status
	
  end
  
  # PATCH/PUT /api/{resource_name}/id
  def update  
	resource_string = pg_call("SELECT fhir.update(fhirbase_json.merge(fhir.read('#{params[:resource_type]}', '#{params[:id]}'),'#{request.body.read}'));")
	resource_json_hash = JSON.parse resource_string
	
	headers['ETag'] = resource_json_hash["meta"]["versionId"]
	
	render json: resource_string, content_type: "application/json+fhir"  
  	#render json: update_resource(params[:resource_type], params[:id], request.body.read), content_type: "application/json+fhir"
  end 
  
  def vread
    resource_string = pg_call("SELECT fhir.vread('#{params[:resource_type]}', /*old_version_id*/ '#{params[:vid]}');")
	render json: resource_string, content_type: "application/json+fhir"
  end
  

  def destroy_session
    request.session_options[:skip] = true
  end

  def request_params
    params.permit(:resource_type, :id)
  end
  
  private
  
end
