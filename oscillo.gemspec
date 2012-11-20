# -*- encoding: utf-8 -*-
require File.expand_path('../lib/oscillo/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Evan Tatarka"]
  gem.email         = ["evan@tatarka.me"]
  gem.description   = %q{Modify and respond to signals, inspired by functional reactive programming}
  gem.summary       = %q{Modify and respond to signals, inspired by functional reactive programming}
  gem.homepage      = "http://www.github.com/evant/oscillo"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "oscillo"
  gem.require_paths = ["lib"]
  gem.version       = Oscillo::VERSION

  gem.add_development_dependency 'yard', '~> 0.8.3'
  gem.add_development_dependency 'redcarpet', '~> 2.2.2'
end
