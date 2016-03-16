# lib/postgres_calls.rb
require 'json'
require 'pg'

module PostgresCalls

  def pg_call(stmt_name, pg_statement, res_type, id)
    
	begin		
		#values = [ { value: 1}, { value: res_type } ]
		#values.push( { value: 2}, { value: id } )
		values = [res_type, id]
		#connection = ActiveRecord::Base.connection
		
		db_parts = ENV['DATABASE_URL'].split(/\/|:|@/)
        username = db_parts[3]
        password = db_parts[4]
        host = db_parts[5]
        db = db_parts[7]
        conn = PG::Connection.open(:host =>  host, :dbname => db, :user=> username, :password=> password)

		#conn = PG::Connection.open(dbname: 'fhir_widget_one_production')
		puts conn.class.name
		puts conn.methods
		#puts connection.raw_connection.class.name
		conn.prepare('test', pg_statement)
		res = conn.exec_prepared('test', values)
	
		#res = connection.execute(%Q{ SELECT fhir.read(#{connection.quote(params[:resource_type])}, #{connection.quote(params[:id])});} ) # Running fhirbase stored procedure
	    conn.close()
		#res =  ActiveRecord::Base.connection.execute(pg_statement) # Running fhirbase stored procedure
	rescue PG::Error => e
		puts e.to_s
		if (e.to_s.include? "relation") && ((e.to_s.include? "does not exist")) then
			return "No table for that resourceType"
		end
	end
	puts res.size().to_s
	resource_as_json_str = ''
	if res.num_tuples() > 0 then
		res_hash = res[0] #First row of query result
		record_hash = res_hash.first #Some kind of wrapper array?
		resource_as_json_str = record_hash.second #string of the json content
	end
	
	return resource_as_json_str
	
  end
  
end