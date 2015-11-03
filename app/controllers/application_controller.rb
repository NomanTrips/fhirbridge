class ApplicationController < ActionController::API
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  
  def get_resource(request_params)
	resource_kind = request_params[resource_type]
	resource_id = request_params[id]
	puts 'getting to get_resource'
	puts resource_kind.to_s
	puts resource_id.to_s
	result = ActiveRecord::Base.connection.execute("SELECT * from '#{resource_kind}' where id='#{resource_id}'")
	puts 'after query exec....'
	return result
  end

end
