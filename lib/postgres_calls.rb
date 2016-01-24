# lib/postgres_calls.rb
require 'json'

module PostgresCalls

  def pg_call(pg_statement)
    
	begin
		res =  ActiveRecord::Base.connection.execute(pg_statement) # Running fhirbase stored procedure
	rescue ActiveRecord::StatementInvalid => e
		if (e.to_s.include? "relation") && ((e.to_s.include? "does not exist")) then
			return "No table for that resourceType"
		end
	end
	
	resource_as_json_str = ''
	if res.size() > 0 then
		res_hash = res[0] #First row of query result
		record_hash = res_hash.first #Some kind of wrapper array?
		resource_as_json_str = record_hash.second #string of the json content
	end
	
	return resource_as_json_str
	
  end
  
end