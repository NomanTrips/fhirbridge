class Api::V1::BaseController < ApplicationController
  #protect_from_forgery with: :null_session

  
  #before_action :destroy_session
  require 'json'

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
	resource_string = get_resource(params[:resource_type], params[:id])
	
	resource_json_hash = JSON.parse resource_string
	headers['ETag'] = resource_json_hash["meta"]["versionId"]
	headers['Last-Modified'] = resource_json_hash["meta"]["lastUpdated"]
	
	render :text => resource_string, content_type: "application/json+fhir"
	#render json: get_resource(params[:resource_type], params[:id]), content_type: "application/json+fhir"
  end

  # POST /api/{plural_resource_name}
  def create
	puts 'line 30'
	resource_string = create_resource(request.body.read)
	resource_json_hash = JSON.parse resource_string
	puts 'line 33'
	headers['ETag'] = resource_json_hash["meta"]["versionId"]
	headers['Location'] = request.original_url + "/#{resource_json_hash["id"]}"
	
	render json: resource_string, content_type: "application/json+fhir"
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
