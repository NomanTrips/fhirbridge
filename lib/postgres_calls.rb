# lib/postgres_calls.rb
require 'json'

module PostgresCalls

  def pg_call(stmt_name, pg_statement, res_type, id)
    
	begin
		
		values = [ { value: 1}, { value: res_type } ]
		values.push( { value: 2}, { value: id } )
		connection = ActiveRecord::Base.connection
		puts connection.prepared_statements?
		connection = ActiveRecord::Base.connection.raw_connection
		puts connection.methods
		puts connection.class.name
		connection.prepare('test', pg_statement)
		res = connection.exec_prepared('test', values)
		connection.close()
		#res =  ActiveRecord::Base.connection.execute(pg_statement) # Running fhirbase stored procedure
	rescue ActiveRecord::StatementInvalid => e
		if (e.to_s.include? "relation") && ((e.to_s.include? "does not exist")) then
			return "No table for that resourceType"
		end
	end
	puts res.size().to_s
	resource_as_json_str = ''
	if res.size() > 0 then
		res_hash = res[0] #First row of query result
		record_hash = res_hash.first #Some kind of wrapper array?
		resource_as_json_str = record_hash.second #string of the json content
	end
	
	return resource_as_json_str
	
  end
  
end