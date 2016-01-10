require 'json'
require 'nokogiri'
require 'postgres_calls'
require 'fhir_clojure_client'
  
class Api::V1::BaseController < ApplicationController
	include PostgresCalls 
	#protect_from_forgery with: :null_session

	#before_action :destroy_session

	# Can't set ETag with the caching? 
  
	def caching_allowed?
		false
	end

	def conformance
		resource_string = pg_get_conformance_statement()
		if (request.headers["Accept"] == 'application/xml+fhir') || (request.headers["Content-Type"] == 'application/xml+fhir') then
			resource_string = ::FhirClojureClient.convert_to_xml(resource_string)
		end	
			
		render text: resource_string, content_type: request.headers["Accept"]
	end
  
	def show
		puts 'ahab slew the whale'
	
		#beginning_time = Time.now	
		#end_time = Time.now
		#puts "Index... #{(end_time - beginning_time)*1000} milliseconds"

		resource_string = pg_get_call(params[:resource_type], params[:id])
	
		if ! resource_string.empty? then
			resource_json_hash = JSON.parse resource_string
			if resource_json_hash["resourceType"] == "OperationOutcome" then
				response_status = 410
			else
				headers['ETag'] = resource_json_hash["meta"]["versionId"]
				headers['Last-Modified'] = resource_json_hash["meta"]["lastUpdated"]
				response_status = 200
			end
		
			if (request.headers["Accept"] == 'application/xml+fhir') then
				resource_string = ::FhirClojureClient.convert_to_xml(resource_string)
			end		
		end
		
		render :text => resource_string, content_type: request.headers["Accept"], :status => response_status
		#render json: get_resource(params[:resource_type], params[:id]), content_type: "application/json+fhir"
	end

	# POST /api/{plural_resource_name}
	def create
	
		if (request.headers["Content-Type"] == 'application/xml+fhir') then
			payload = ::FhirClojureClient.convert_to_json(request.body.read) # request.body.read --> xml body from request
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
			resource_string = ::FhirClojureClient.convert_to_xml(resource_string)
		end	
	
		render :text => resource_string, :status => 201
		#render json: create_resource(request.body.read), content_type: "application/json+fhir" <-- This one works 
	end
 
	#  DELETE [base]/[type]/[id]
	def delete
		resource_string = pg_delete_call(params[:resource_type], params[:id])

		if ! resource_string.empty? then
			resource_json_hash = JSON.parse resource_string
			if resource_json_hash["resourceType"] == "OperationOutcome" then
				response_status = 204
				if resource_json_hash.key?("meta") then
					headers['ETag'] = resource_json_hash["meta"]["versionId"]
				end
			end
				
		end
		

		render :text => resource_string, :status => response_status
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
