# -*- encoding: utf-8 -*-
require File.expand_path('../lib/mongoid/slugify/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Pavel Forkert"]
  gem.email         = ["fxposter@gmail.com"]
  gem.description   = "Provides a simple way to add slug generation to a Mongoid model"
  gem.summary       = "Managing slugs in Mongoid models"
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "mongoid-slugify"
  gem.require_paths = ["lib"]
  gem.version       = Mongoid::Slugify::VERSION

  gem.add_runtime_dependency 'activesupport', '~> 3.0'
  gem.add_runtime_dependency 'mongoid', '~> 2.0'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'database_cleaner'
end
