class Api::V1::BaseController < ApplicationController
  #protect_from_forgery with: :null_session

  #before_action :destroy_session
  require 'json'

  def caching_allowed?
    false
  end

  def show
	resource_string = get_resource(params[:resource_type], params[:id])
	resource_json_hash = JSON.parse resource_string
    etag_str = resource_json_hash["meta"]["versionId"]
	headers['ETag'] = etag_str
	render json: resource_string, content_type: "application/json+fhir"
	#render json: get_resource(params[:resource_type], params[:id]), content_type: "application/json+fhir"
  end

  # POST /api/{plural_resource_name}
  def create
	puts 'entering create....'
	puts request.body.read
	render json: create_resource(request.body.read), content_type: "application/json+fhir"

	#if get_resource.save
	 # render :show, status: :created
	#else
	 # render json: get_resource.errors, status: :unprocessable_entity
	#end
  
  end
  
  def search
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
	puts 'This is the search string: ' + @search_string
	
	render json: search_for_resource(params[:resource_type], @search_string), content_type: "application/json+fhir"
  end
  
  # PATCH/PUT /api/{resource_name}/id
  def update  
	render json: update_resource(params[:resource_type], params[:id], request.body.read), content_type: "application/json+fhir"
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
