class ApplicationController < ActionController::API
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  
    def get_resource(resource_type, id)
		res =  ActiveRecord::Base.connection.execute("SELECT fhir.read('#{resource_type}', '#{id}');")
		#puts fhirbase_query_result.fname(1)
		#puts fhirbase_query_result.fname(2)
		#content_col_index = fhirbase_query_result.fnumber('content')
		puts 'after query exec...'
		puts 'res class: ' + res.class.to_s
		
		res.each{|tuple| puts tuple.length}
		
		res_hash = res[0]
		record_hash = res_hash.first
		puts 'record_hash class:' + record_hash.class.to_s
		result = record_hash.second
		puts 'result class: ' + result.class.to_s
		
		#puts 'done printing the field names.'
		#puts res[0].size
		#json_content = fhirbase_query_result.getvalue(0, 1)
		#puts 'line 10'
		#puts json_content.class
		#result = json_content
		#record = result.to_a()
		#result = record.first
		#record_a = result.first
		#json_content_str = record_a.second
		#result = json_content_str
	return result
  end
  
end
