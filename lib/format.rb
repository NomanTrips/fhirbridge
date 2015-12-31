# lib/format.rb
	$CLASSPATH << (Rails.root.to_s + "/lib/jars")
	$CLASSPATH << (Rails.root.to_s + "/lib/deps")
	# clojure fhir xml-json converting middleware dependencies
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

	module Format
	  
	  def convert_to_xml(resource_as_json_str)
		
		core = JRClj.new #clojure core
		fhir = JRClj.new "fhir.core"
		idx = fhir.index('app/assets/javascripts/profiles-resources.json', 'app/assets/javascripts/profiles-types.json')
		resourceparsed = fhir.parse(idx, resource_as_json_str)
		resource_as_xml_str = fhir.generate(idx, core.keyword("xml"), resourceparsed)
		
		return resource_as_xml_str
		
	  end
	  
	  def convert_to_json(resource_as_xml_str)
		
		core = JRClj.new #clojure core
		fhir = JRClj.new "fhir.core"
		idx = fhir.index('app/assets/javascripts/profiles-resources.json', 'app/assets/javascripts/profiles-types.json')
		payloadparsed = fhir.parse(idx, resource_as_xml_str)
		resource_as_json_str = fhir.generate(idx, core.keyword("json"), payloadparsed)	
		
		return resource_as_json_str
		
	  end
	  
	  
	end