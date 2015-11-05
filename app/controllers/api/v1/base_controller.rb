class Api::V1::BaseController < ApplicationController
  #protect_from_forgery with: :null_session

  #before_action :destroy_session
  
  def show
	puts 'getting to show...'
	puts params
    #render json: get_resource(params[:resource_type], params[:id])
	render JSON.pretty_generate( json: get_resource(params[:resource_type], params[:id]) )
  end

  def destroy_session
    request.session_options[:skip] = true
  end

  def request_params
    params.permit(:resource_type, :id)
  end
  
  private
  
end
