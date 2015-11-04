class ApplicationController < ActionController::API
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  
  def get_resource(resource_type, id)
	#puts request_params
	#resource_kind = request_params[resource_type]
	#resource_id = request_params[id]
	puts 'getting to get_resource'
	puts resource_type
	puts id
	#result = ActiveRecord::Base.connection.execute("SELECT * from '#{resource_type}' where id='#{id}'")
	#result =  ActiveRecord::Base.connection.execute("SELECT * FROM search('Patient'::text,'id=#{id}')")
	result =  ActiveRecord::Base.connection.execute("call SELECT fhir.read('Patient', '#{id}');")
	#result =  ActiveRecord::Base.connection.execute("SELECT content FROM resource WHERE logical_id = '#{id}' AND resource_type = 'Patient';")
	#fhir.read('Patient', 'c6f20b3a...');
	puts 'after query exec....'
	return result
  end

end
