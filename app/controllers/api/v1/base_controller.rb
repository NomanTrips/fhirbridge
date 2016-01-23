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
  
  def conformance
  
    is_request_format_xml = true # default the response to xml format unless otherwise requested
	if (request.headers["Accept"] == 'application/json+fhir') || (request.headers["Content-Type"] == 'application/xml+fhir') then
	  is_request_format_xml = false
  end
	
    resource_string = pg_get_conformance_statement()
    
	if is_request_format_xml then
	  resource_string = ::FhirClojureClient.convert_to_xml(resource_string)
    end	
			
	render text: resource_string, content_type: request.headers["Accept"]
  end
  
  def show
    puts 'ahab slew the whale'
		
    is_request_format_xml = true # default the response to xml format unless otherwise requested
	if (request.headers["Accept"] == 'application/json+fhir') then
	  is_request_format_xml = false
    end
		
    #beginning_time = Time.now	
	#end_time = Time.now
	#puts "Index... #{(end_time - beginning_time)*1000} milliseconds"
	if !(params[:id] =~ /^[A-Za-z0-9\-\.]{1,64}$/) then
	  response_status = 400
	  render :text => '', content_type: request.headers["Accept"], :status => response_status
	  return
	end
	
	resource_string = ''
	does_res_exist = pg_does_exist_call(params[:resource_type], params[:id])
	if does_res_exist then
		resource_string = pg_get_call(params[:resource_type], params[:id])
	    if resource_string == "No table for that resourceType" then
          response_status = 404
        else
          resource_json_hash = JSON.parse resource_string
          if resource_json_hash["resourceType"] == "OperationOutcome" then #deleted resource
            response_status = 410
          else
            headers['ETag'] = resource_json_hash["meta"]["versionId"]
            headers['Last-Modified'] = resource_json_hash["meta"]["lastUpdated"]
            response_status = 200
          end
		
          if is_request_format_xml then
            resource_string = ::FhirClojureClient.convert_to_xml(resource_string)
          end
      
	    end
	  
	else
	  response_status = 404
	end
		
    render :text => resource_string, content_type: request.headers["Accept"], :status => response_status

  end

  # POST /api/{plural_resource_name}
  def create

    is_request_format_xml = true # default the response to xml format unless otherwise requested
	if (request.headers["Content-Type"] == 'application/json+fhir') then
	  is_request_format_xml = false
    end
	
    if is_request_format_xml then
      payload = ::FhirClojureClient.convert_to_json(request.body.read) # request.body.read --> xml body from request
    else
      payload = request.body.read # json
    end
	
    resource_string = pg_post_call(payload)

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
    
	is_request_format_xml = true # default the response to xml format unless otherwise requested
	if (request.headers["Content-Type"] == 'application/json+fhir') || (request.headers["Accept"] == 'application/json+fhir') then
	  is_request_format_xml = false
    end
	
    resource_string = pg_delete_call(params[:resource_type], params[:id])

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

	resource_string = pg_search_call(params[:resource_type], @search_string)

	is_request_format_xml = true # default the response to xml format unless otherwise requested
	if (request.headers["Accept"] == 'application/json+fhir') || (request.headers["Content-Type"] == 'application/json+fhir') then
		is_request_format_xml = false
	end
		
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
	resource_string = update_resource(params[:resource_type], params[:id], request.body.read)
	resource_json_hash = JSON.parse resource_string
	
	headers['ETag'] = resource_json_hash["meta"]["versionId"]
	
	render json: resource_string, content_type: "application/json+fhir"  
  	#render json: update_resource(params[:resource_type], params[:id], request.body.read), content_type: "application/json+fhir"
  end 
  
  def vread
	render json: vread_resource(params[:resource_type], params[:id], params[:vid]), content_type: "application/json+fhir"
  end
  

  def destroy_session
    request.session_options[:skip] = true
  end

  def request_params
    params.permit(:resource_type, :id)
  end
  
  private
  
end
