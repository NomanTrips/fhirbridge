class ApplicationController < ActionController::API
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  require 'json'
  $CLASSPATH << (Rails.root.to_s + "/lib/jars")
  $CLASSPATH << (Rails.root.to_s + "/lib/deps")
  require 'java'
  puts 'getting to line 9...' 
   Dir["#{File.dirname(__FILE__)}/lib/deps/*.jar"].each do |jar|
    puts "requiring: #{jar}"
    require jar
  end
  puts 'after require loop'
  #require 'lib/jars/fhir-dstu1-0.0.82.2943.jar'
  #require 'lib/jars/FhirConvUtilsOne.jar'
  #require 'lib/jars/gson-2.5.jar'
  #require 'lib/jars/Saxon-HE-9.4.jar'
  #require 'lib/jars/xpp3_min-1.1.4c.jar'
  #require 'lib/jars/xpp3_xpath-1.1.4c.jar'
  #require 'lib/jars/xpp3-1.1.4c.jar'
  #java_import 'fhirconverterutils.FhirConvUtil';
  #java_import 'java.io.ByteArrayInputStream';
  #java_import 'java.io.FileInputStream';
  #java_import 'java.io.FileNotFoundException';
  #java_import 'java.io.InputStream';
  #java_import 'java.nio.charset.StandardCharsets';
  #java_import 'org.hl7.fhir.instance.formats.JsonParser';
  #java_import 'org.hl7.fhir.instance.formats.XmlParser';
  #java_import 'org.hl7.fhir.instance.formats.JsonComposer';
  #java_import 'org.hl7.fhir.instance.formats.XmlComposer';
  #java_import 'org.hl7.fhir.instance.model.Resource';


    def get_conformance_statement()
		res =  ActiveRecord::Base.connection.execute("SELECT fhir.read('Conformance', 'fb5ef8ec-55da-4718-9fd4-5a4c930ee8c9');") # Running fhirbase stored procedure
		
		if res.ntuples() > 0 then
			res_hash = res[0] #First row of query result
			record_hash = res_hash.first #Some kind of wrapper array?
			result = record_hash.second #string of the json content
		end
	
	return result
  end
  
    def get_resource(resource_type, id, accept_header)
		puts 'getting to show...'
		res =  ActiveRecord::Base.connection.execute("SELECT fhir.read('#{resource_type}', '#{id}');") # Running fhirbase stored procedure

		if res.size() > 0 then
			res_hash = res[0] #First row of query result
			record_hash = res_hash.first #Some kind of wrapper array?
			result = record_hash.second #string of the json content
		end
		
		core = JRClj.new
		puts core.inc 3
		
		#clj = JRClj.new "clojure.contrib.str-utils"
		#puts clj.str_join ":", [1,2,3]
		

		fhir = JRClj.new "fhir.fhir.core"
		pt = "{\"resourceType\": \"Patient\",\"name\": [{\"text\":\"Smith\"}],\"active\": true}"
		idx = fhir.index "profiles/profiles-resources.json" "profiles/profiles-types.json"
		ptparsed = fhir.parse idx pt
		puts fhir.generate idx :xml ptparsed
		#if accept_header = "application/xml+fhir" then
		#	fc = FhirConvUtil.new
		#	jsonresource = fc.fromJsontoResource(result)
		#	result = fc.ResourceToXml(jsonresource)
		#end
		
		#fc = FhirConvUtil.new
		#jsonresource = fc.fromJsontoResource(result)
		#str = fc.ResourceToXml(jsonresource)
		#puts str
		
	return result
  end

    def delete_resource(resource_type, id)
		res =  ActiveRecord::Base.connection.execute("SELECT fhir.delete('#{resource_type}', '#{id}');") # Running fhirbase stored procedure
		
		if res.ntuples() > 0 then
			res_hash = res[0] #First row of query result
			record_hash = res_hash.first #Some kind of wrapper array?
			result = record_hash.second #string of the json content
		end
	
	return result
  end
  
	def create_resource(payload, content_type_header)
	# SELECT fhir.create('{"resourceType":"Patient", "name": [{"given": ["John"]}]}')
		#payload_escaped = %q[payload]
		#payload_as_json = Hash.from_xml(payload).to_json
		#puts payload_as_json.to_s
		
		if content_type_header = "application/xml+fhir" then
			fc = FhirConvUtil.new
			xmlresource = fc.fromXmltoResource(payload)
			payload_converted = fc.ResourceToJson(xmlresource)			
		else
			payload_converted = payload
		end
		
		res =  ActiveRecord::Base.connection.execute("SELECT fhir.create('#{payload_converted}');") # Running fhirbase stored procedure

		if res.size() > 0 then
			res_hash = res[0] #First row of query result
			record_hash = res_hash.first #Some kind of wrapper array?
			result = record_hash.second #string of the json content
		end

		#if content_type_header = "application/xml+fhir" then
			
		#	if not( (defined?(fc)).nil? ) # will now return true or false
		#		fc = FhirConvUtil.new
		#	end
			
		#	jsonresource = fc.fromJsontoResource(result)
		#	result = fc.ResourceToXml(jsonresource)
		#end
		
		return result
	
	end
	
	def search_for_resource(resource_type, searchString)
	# select fhir.search('Patient', 'given=john')
		res =  ActiveRecord::Base.connection.execute("SELECT fhir.search('#{resource_type}', '#{searchString}');") # Running fhirbase stored procedure

		if res.ntuples() > 0 then
			res_hash = res[0] #First row of query result
			record_hash = res_hash.first #Some kind of wrapper array?
			result = record_hash.second #string of the json content
		end
	
		return result
	
	end
	
    def update_resource(resource_type, id, payload)
		res =  ActiveRecord::Base.connection.execute("SELECT fhir.update(fhirbase_json.merge(fhir.read('#{resource_type}', '#{id}'),'#{payload}'));") # Running fhirbase stored procedure
		
		#SELECT fhir.update(fhirbase_json.merge(fhir.read('#{resource_type}', '#{id}'),'#{payload}'));

		if res.ntuples() > 0 then
			res_hash = res[0] #First row of query result
			record_hash = res_hash.first #Some kind of wrapper array?
			result = record_hash.second #string of the json content
		end
	
	return result
  end
  
    def vread_resource(resource_type, id, vid)
		res =  ActiveRecord::Base.connection.execute("SELECT fhir.vread('#{resource_type}', /*old_version_id*/ '#{vid}');") # Running fhirbase stored procedure
		
		if res.ntuples() > 0 then
			res_hash = res[0] #First row of query result
			record_hash = res_hash.first #Some kind of wrapper array?
			result = record_hash.second #string of the json content
		end
	
	return result
  end
  
end
