Gem::Specification.new do |gem_spec|
  gem_spec.name        = 'rsweb'
  gem_spec.version     = '0.0.1'
  gem_spec.date        = '2015-01-03'
  gem_spec.executables << 'rsweb'
  gem_spec.summary     = "Manages Static Websites served on Rackspace Cloudfiles"
  gem_spec.description = "Manages Static Websites served on Rackspace Cloudfiles"
  gem_spec.authors     = ["Tom Harvey"]
  gem_spec.email       = 'tom@alush.co.uk'
  gem_spec.files       = Dir['Rakefile', '{bin,lib,test}/**/*', 'README*', 'LICENSE'] & `git ls-files -z`.split("\0")
  gem_spec.homepage    = 'http://rubygems.org/gems/rsweb'
  gem_spec.license     = 'GPL-2'
  gem_spec.add_dependency("fog")
  gem_spec.add_dependency("gitlab-grit", ">=2.7")
  gem_spec.add_development_dependency("minitest")
  gem_spec.add_development_dependency("coveralls")
end
