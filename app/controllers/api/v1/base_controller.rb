class Api::V1::BaseController < ApplicationController
  #protect_from_forgery with: :null_session

  #before_action :destroy_session
  
  
  def show
	puts 'entering show'
    render json: get_resource(params[:resource_type], params[:id]), content_type: "application/json+fhir"
	#render JSON.pretty_generate( json: get_resource(params[:resource_type], params[:id]) )
	#render json: JSON.pretty_generate( get_resource(params[:resource_type], params[:id]) )
  end

  # POST /api/{plural_resource_name}
  def create
	puts 'entering create....'
	puts request.body.read
	render json: create_resource(request.body.read)

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
	
	render json: search_for_resource(params[:resource_type], @search_string)
  end
  
  # PATCH/PUT /api/{resource_name}/id
  def update  
	render json: update_resource(params[:resource_type], params[:id], request.body.read)
  end 
  
  def vread
	render json: vread_resource(params[:resource_type], params[:id], params[:vid])
  end
  

  def destroy_session
    request.session_options[:skip] = true
  end

  def request_params
    params.permit(:resource_type, :id)
  end
  
  private
  
end
