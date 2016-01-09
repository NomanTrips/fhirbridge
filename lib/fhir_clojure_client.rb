# Class to integrate Fhir client clojure library for converting json to xml and other utils
# https://github.com/fhirbase/fhir.clj

# dependency jars for clojure client
$CLASSPATH << (Rails.root.to_s + "/lib/jars")
$CLASSPATH << (Rails.root.to_s + "/lib/deps")
require 'java'
require 'lib/deps/cheshire-5.4.0.jar'
require 'lib/deps/clj-time-0.9.0.jar'
require 'lib/deps/clojure-1.6.0.jar'
require 'lib/deps/data.xml-0.0.8.jar'
require 'lib/deps/fhir-0.1.1.jar'
require 'lib/deps/fs-1.4.6.jar'
require 'lib/deps/http-kit-2.1.16.jar'
require 'lib/deps/tools.namespace-0.2.8.jar'
require 'lib/deps/commons-compress-1.8.jar'
require 'lib/deps/jackson-core-2.4.4.jar'
require 'lib/deps/jackson-dataformat-cbor-2.4.4.jar'
require 'lib/deps/jackson-dataformat-smile-2.4.4.jar'
require 'lib/deps/joda-time-2.6.jar'
require 'lib/deps/tigris-0.1.1.jar'
require 'lib/deps/xz-1.5.jar'

class FhirClojureClient
	
	@@clojure_core = JRClj.new #clojure core
	@@fhir_core = JRClj.new "fhir.core"
	@@idx = @@fhir_core.index('app/assets/javascripts/profiles-resources.json', 'app/assets/javascripts/profiles-types.json')
  
	def self.clojure_core
		@@clojure_core
	end
  
	def self.fhir_core
		@@fhir_core
	end
  
	def self.idx
		@@idx
	end
  
	def self.convert_to_xml(resource_as_json_str)

		resource_parsed = @@fhir_core.parse(idx, resource_as_json_str)
		resource_as_xml_str = @@fhir_core.generate(idx, @@clojure_core.keyword("xml"), resource_parsed)
		
		return resource_as_xml_str
		
	end
	
	def self.convert_to_json(resource_as_xml_str)
				
		payload_parsed = @@fhir_core.parse(idx, resource_as_xml_str)			
		resource_as_json_str = @@fhir_core.generate(idx, @@clojure_core.keyword("json"), payload_parsed)	
		
		return resource_as_json_str
		
	end
  
end