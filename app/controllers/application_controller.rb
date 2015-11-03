class ApplicationController < ActionController::API
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  
  def get_resource(resource_type, id)
	result = ActiveRecord::Base.connection.execute("SELECT * from '#{resource_type}' where id='#{id}'")
	return result
  end

end
