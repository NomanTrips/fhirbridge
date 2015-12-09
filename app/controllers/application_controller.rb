class ApplicationController < ActionController::API
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  require 'json'
$CLASSPATH << (Rails.root.to_s + "/lib/jars")
  require 'java'
require 'lib/jars/fhir-dstu1-0.0.82.2943.jar'
require 'lib/jars/FhirConvUtilsOne.jar'
require 'lib/jars/gson-2.5.jar'
require 'lib/jars/Saxon-HE-9.4.jar'
require 'lib/jars/xpp3_min-1.1.4c.jar'
require 'lib/jars/xpp3_xpath-1.1.4c.jar'
require 'lib/jars/xpp3-1.1.4c.jar'
java_import 'fhirconverterutils.FhirConvUtil';
java_import java.lang.System

java_import 'java.io.ByteArrayInputStream';
java_import 'java.io.FileInputStream';
java_import 'java.io.FileNotFoundException';
java_import 'java.io.InputStream';
java_import 'java.nio.charset.StandardCharsets';

java_import 'org.hl7.fhir.instance.formats.JsonParser';
java_import 'org.hl7.fhir.instance.formats.XmlParser';
java_import 'org.hl7.fhir.instance.formats.JsonComposer';
java_import 'org.hl7.fhir.instance.formats.XmlComposer';
java_import 'org.hl7.fhir.instance.model.Resource';

		#fhir_conv = fhirconverterutils.FhirConvUtil 
		#fc = fhir_conv.new

		#puts fc.TestPrinter

	
class XmlConvert 
    def self.classify
      xmlconverter = FhirConvUtil.new
    end
end


    def get_conformance_statement()
		res =  ActiveRecord::Base.connection.execute("SELECT fhir.read('Conformance', 'fb5ef8ec-55da-4718-9fd4-5a4c930ee8c9');") # Running fhirbase stored procedure
		
		if res.ntuples() > 0 then
			res_hash = res[0] #First row of query result
			record_hash = res_hash.first #Some kind of wrapper array?
			result = record_hash.second #string of the json content
		end
	
	return result
  end
  
    def get_resource(resource_type, id)
		puts 'getting to get_resource'
		#fhirXmlconv = XmlConvert.new()
		#fhirXmlconv.TestPrinter()
		version = System.getProperties["java.runtime.version"]
		puts version.to_s
		#fhirXmlconv = XmlConvert.new()
		#fhirXmlconv.TestPrinter()
		#fc = FhirConvUtil.new
		#fc.TestPrinter
		
		#fhir_conv = fhirconverterutils.FhirConvUtil 
		#fc = fhir_conv.new

		#puts fc.TestPrinter
		fc = FhirConvUtil.new
		fc.TestPrinter
		res =  ActiveRecord::Base.connection.execute("SELECT fhir.read('#{resource_type}', '#{id}');") # Running fhirbase stored procedure
		#puts 'res status: ' + res.cmd_status()
		#puts 'tuple amt: ' + res.ntuples().to_s

		if res.size() > 0 then
			res_hash = res[0] #First row of query result
			record_hash = res_hash.first #Some kind of wrapper array?
			result = record_hash.second #string of the json content
		end
		
		Resource res = fc.fromJsontoResource(result)
		result = fc.ResourceToXml(res)
		puts 'res as xml str.....'
		puts result
		puts 'end res as xml str.....'
		
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
  
	def create_resource(payload)
	# SELECT fhir.create('{"resourceType":"Patient", "name": [{"given": ["John"]}]}')
		#payload_escaped = %q[payload]
		payload_as_json = Hash.from_xml(payload).to_json
		puts payload_as_json.to_s
		res =  ActiveRecord::Base.connection.execute("SELECT fhir.create('#{payload_as_json}');") # Running fhirbase stored procedure

		if res.ntuples() > 0 then
			res_hash = res[0] #First row of query result
			record_hash = res_hash.first #Some kind of wrapper array?
			result = record_hash.second #string of the json content
		end
	
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
