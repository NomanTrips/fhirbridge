class Api::V1::BaseController < ApplicationController
  #protect_from_forgery with: :null_session

  #before_action :destroy_session
  require 'json'

  # Can't set ETag with the caching? 
  def caching_allowed?
    false
  end

  def show
	resource_string = get_resource(params[:resource_type], params[:id])
	
	resource_json_hash = JSON.parse resource_string
	headers['ETag'] = resource_json_hash["meta"]["versionId"]
	headers['Last-Modified'] = resource_json_hash["meta"]["lastUpdated"]
	
	render json: resource_string, content_type: "application/json+fhir"
	#render json: get_resource(params[:resource_type], params[:id]), content_type: "application/json+fhir"
  end

  # POST /api/{plural_resource_name}
  def create
	resource_string = create_resource(request.body.read)
	resource_json_hash = JSON.parse resource_string
	
	headers['ETag'] = resource_json_hash["meta"]["versionId"]
	headers['Location'] = request.original_url + "/#{resource_json_hash["id"]}"
	
	render json: resource_string, content_type: "application/json+fhir"
	#render json: create_resource(request.body.read), content_type: "application/json+fhir" <-- This one works 
  end
  
  def search
	# Getting the search params out of the URL key-value pairs and then putting them into a string that fhirbase can use to search
	query_strings = request.query_parameters.to_hash()
	@search_string = ""
	query_strings.each do |key,value|
		puts "#{key.to_s}---#{value.to_s}"
		puts @search_string
		puts 'juju'
		if @search_string.empty? then
			@search_string = "#{key.to_s}=#{value.to_s}"
		else
			@search_string.concat "&#{key.to_s}=#{value.to_s}"
		end
	end

	resource_string = search_for_resource(params[:resource_type], @search_string)
	
	resource_json_hash = JSON.parse resource_string
	headers['Last-Modified'] = resource_json_hash["meta"]["lastUpdated"]
	
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
