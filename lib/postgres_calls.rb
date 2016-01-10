# lib/postgres_calls.rb
require 'json'

module PostgresCalls
  
  def pg_get_call(resource_type, id)
    
	begin
		res =  ActiveRecord::Base.connection.execute("SELECT fhir.read('#{resource_type}', '#{id}');") # Running fhirbase stored procedure
	rescue ActiveRecord::StatementInvalid => e
		puts ' '
		puts e.to_s
		puts ' '
		if (e.to_s.include? "relation") && ((e.to_s.include? "does not exist")) then
			return "No table for that resourceType"
	end
	
	resource_as_json_str = ''
	if res.size() > 0 then
		res_hash = res[0] #First row of query result
		record_hash = res_hash.first #Some kind of wrapper array?
		resource_as_json_str = record_hash.second #string of the json content
		puts 'pg res has size'
	end
	

	puts "resource as json str: #{resource_as_json_str}"
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
  
  def pg_delete_call(resource_type, id)	
	
	res =  ActiveRecord::Base.connection.execute("SELECT fhir.delete('#{resource_type}', '#{id}');") # Running fhirbase stored procedure
	resource_as_str = ''		
	if res.size() > 0 then
		res_hash = res[0] #First row of query result
		record_hash = res_hash.first #Some kind of wrapper array?
		resource_as_str = record_hash.second #operation outcome json str
				puts 'pg res has size'
	end

	puts "resource as json str: #{resource_as_str}"
	
	return resource_as_str
	
  end
  
    def pg_get_conformance_statement()
		res =  ActiveRecord::Base.connection.execute("SELECT fhir.read('Conformance', 'fb5ef8ec-55da-4718-9fd4-5a4c930ee8c9');") # Running fhirbase stored procedure
		
		if res.size() > 0 then
			res_hash = res[0] #First row of query result
			record_hash = res_hash.first #Some kind of wrapper array?
			result = record_hash.second #string of the json content
		end
	
	return result
  end
  
end