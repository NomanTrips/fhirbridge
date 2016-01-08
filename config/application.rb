require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'java'
#require 'lib/jars/fhir-dstu1-0.0.82.2943.jar'
#require 'lib/jars/FhirConvUtilsOne.jar'
#require 'lib/jars/gson-2.5.jar'
#require 'lib/jars/Saxon-HE-9.4.jar'
#require 'lib/jars/xpp3_min-1.1.4c.jar'
#require 'lib/jars/xpp3_xpath-1.1.4c.jar'
#require 'lib/jars/xpp3-1.1.4c.jar'

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

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)



module FhirWidgetOne
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
	
	#config.x.whatever.you.want = 42	
	#config.x.clojure.core = JRClj.new #clojure core
		#config.after_initialize do
		#	puts 'running after initialize......!'
		#	core = JRClj.new #clojure core	
		#	Rails.cache.write 'clojure_core', core
		#	puts 'put it into the cache?'
		#end
  end
end
