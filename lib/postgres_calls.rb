# lib/postgres_calls.rb
require 'json'

module PostgresCalls
  
  def pg_get_call(resource_type, id)
    
	res =  ActiveRecord::Base.connection.execute("SELECT fhir.read('#{resource_type}', '#{id}');") # Running fhirbase stored procedure
	resource_as_json_str = ''
	if res.size() > 0 then
		res_hash = res[0] #First row of query result
		record_hash = res_hash.first #Some kind of wrapper array?
		resource_as_json_str = record_hash.second #string of the json content
	end
	
	return resource_as_json_str
	
  end
  
  def pg_post_call(payload)	
	
	res =  ActiveRecord::Base.connection.execute("SELECT fhir.create('#{payload}');") # Running fhirbase stored procedure
	resource_as_str = ''
	if res.size() > 0 then
		res_hash = res[0] #First row of query result
		record_hash = res_hash.first #Some kind of wrapper array?
		resource_as_str = record_hash.second #string of the json content
	end
	
	return resource_as_str
	
  end
  
end