require 'yaml'

# == Setup some config outside of the project
#
# ==== Example
# See the example_settings.yml file and the useage in connection.rb initialize method
#
module Settings
	extend self

	# === Loads a YAML file
	#
	# YAML > Hash and the first level of keys become readable attributes of Settings
	# 
	# * *Args*    :
	#   - +filename+ -> String path to the config file
	#
	def load!(filename)
		settings = YAML::load_file(filename)
		settings.each do |key, value|
			if value.class == Hash
				value = self.symbolize(value)
			end
			self.instance_variable_set("@#{key}", value)
			self.class.send(:define_method, key, proc{self.instance_variable_get("@#{key}")})
		end
	end

	# === Converts the keys from strings to symbols
	#
	# So far, for ease of use in Fog connections
	# 
	# * *Args*    :
	#   - +hash_object+ -> The second level of the config hash
	# * *Returns* :
	#   - A Hash containing keys as symbols where once were strings
	#
	def symbolize(hash_obj)
		symbolized_hash = {}
		hash_obj.each do |key, value|
			symbolized_hash[key.to_sym] = value
		end
		return symbolized_hash
	end

end

Settings.load!(ENV["HOME"] + "/.rsweb/settings.yml")
