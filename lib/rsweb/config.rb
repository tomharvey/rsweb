require 'yaml'

module Settings
	extend self

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

	def symbolize(hash_obj)
		symbolized_hash = {}
		hash_obj.each do |key, value|
			symbolized_hash[key.to_sym] = value
		end
		return symbolized_hash
	end

end

Settings.load!("settings.yml")
