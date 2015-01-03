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
		self.create_instance_variables(settings)
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

	# === Create instance variables from settings
	# 
	# * *Args*    :
	#   - +settings_hash+ -> The first level of the config hash
	# * *Returns* :
	#   - A Hash containing keys as symbols where once were strings
	#
	def create_instance_variables(settings_hash)
		settings_hash.each do |key, value|
			# Symbolise hash keys
			if value.class == Hash
				value = self.symbolize(value)
			end
			self.instance_variable_set("@#{key}", value)
			self.class.send(:define_method, key, proc{self.instance_variable_get("@#{key}")})
		end
	end

end

# Location of the settings file
settings_file = ENV["HOME"] + "/.rsweb/settings.yml"

if File.exists?(settings_file)
	Settings.load!(settings_file)
end
