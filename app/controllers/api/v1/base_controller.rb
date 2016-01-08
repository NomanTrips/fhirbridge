require 'json'
require 'nokogiri'
require 'postgres_calls'
require 'format'
require 'clojure_core'
  
class Api::V1::BaseController < ApplicationController
	include PostgresCalls 
	include Format
  #protect_from_forgery with: :null_session

  
  #before_action :destroy_session

  # Can't set ETag with the caching? 
  def caching_allowed?
    false
  end

   def conformance
	resource_string = get_conformance_statement()	
	render json: resource_string, content_type: "application/json+fhir"
  end
  
  def show
	puts 'ahab slew the whale'
	
	beginning_time = Time.now
	::ClojureCore.clojurecore
	end_time = Time.now
	puts "Clojure core create... #{(end_time - beginning_time)*1000} milliseconds"

	beginning_time = Time.now	
	fcore = ::ClojureCore.fhircore
	end_time = Time.now
	puts "Fhir core create... #{(end_time - beginning_time)*1000} milliseconds"

	beginning_time = Time.now	
	indexer = ::ClojureCore.idx
	#idx = fcore.index('app/assets/javascripts/profiles-resources.json', 'app/assets/javascripts/profiles-types.json')
	end_time = Time.now
	puts "Index... #{(end_time - beginning_time)*1000} milliseconds"
	



	resource_string = pg_get_call(params[:resource_type], params[:id])
	
	
	resource_json_hash = JSON.parse resource_string
	headers['ETag'] = resource_json_hash["meta"]["versionId"]
	headers['Last-Modified'] = resource_json_hash["meta"]["lastUpdated"]
	
	if (request.headers["Accept"] == 'application/xml+fhir') then
		resource_string = convert_to_xml(resource_string)
	end
	
	
	render :text => resource_string, content_type: request.headers["Accept"]
	#render json: get_resource(params[:resource_type], params[:id]), content_type: "application/json+fhir"
  end

  # POST /api/{plural_resource_name}
  def create
	
	if (request.headers["Content-Type"] == 'application/xml+fhir') then
		payload = convert_to_json(request.body.read) # request.body.read --> xml body from request
	else
		payload = request.body.read # json
	end
	
	resource_string = pg_post_call(payload)
	
	# set response headers using data from json string retrieved from fhirbase
	resource_json_hash = JSON.parse resource_string
	headers['ETag'] = resource_json_hash["meta"]["versionId"]
	headers['Location'] = request.original_url + "/#{resource_json_hash["id"]}"
	headers['Content-Type'] = request.headers["Content-Type"]

	# conv response string back to requested format if xml
	if (request.headers["Content-Type"] == 'application/xml+fhir') then
		resource_string = convert_to_xml(resource_string)
	end	
	
	render :text => resource_string, :status => 201
	#render json: create_resource(request.body.read), content_type: "application/json+fhir" <-- This one works 
  end
 
  #  DELETE [base]/[type]/[id]
  def delete
	resource_string = delete_resource(params[:resource_type], params[:id])
	resource_json_hash = JSON.parse resource_string
	
	headers['ETag'] = resource_json_hash["meta"]["versionId"]
	
	render json: resource_string, content_type: "application/json+fhir"
  end
  
  def search
	# Getting the search params out of the URL key-value pairs and then putting them into a string that fhirbase can use to search
	puts params[:resource_type]
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
	puts @search_string
	resource_string = search_for_resource(params[:resource_type], @search_string)
	
	resource_json_hash = JSON.parse resource_string
	#headers['Last-Modified'] = resource_json_hash["meta"]["lastUpdated"] <-- Since it's a search set collection which last modified do we grab?
	
	render json: resource_string, content_type: "application/json+fhir"
	
	#render json: search_for_resource(params[:resource_type], @search_string), content_type: "application/json+fhir" <-- original code that worked
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
