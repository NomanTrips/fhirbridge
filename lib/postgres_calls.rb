# lib/postgres_calls.rb
require 'json'
require 'pg'

module PostgresCalls

  def pg_call(pg_statement, query_params)
    
	begin		
		# Parse the DB connect info from the database.yml
		db_parts = ENV['DATABASE_URL'].split(/\/|:|@/)
        username = db_parts[3]
        password = db_parts[4]
        host = db_parts[5]
        db = db_parts[7]
        
        conn = PG::Connection.open(:host =>  host, :dbname => db, :user=> username, :password=> password)
		conn.prepare('fhirbase_call', pg_statement) # use prepared stmt to protect against sql injection
		res = conn.exec_prepared('fhirbase_call', query_params)
	
        conn.close()
		#res =  ActiveRecord::Base.connection.execute(pg_statement) # Running fhirbase stored procedure
	rescue PG::Error => e
		if (e.to_s.include? "relation") && ((e.to_s.include? "does not exist")) then
			return "No table for that resourceType"
		end
	end
	resource_as_json_str = ''
	if res.num_tuples() > 0 then
		res_hash = res[0] #First row of query result
		record_hash = res_hash.first #Some kind of wrapper array?
		resource_as_json_str = record_hash.second #string of the json content
	end
	
	return resource_as_json_str
	
  end
  
end