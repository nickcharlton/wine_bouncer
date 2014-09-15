# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wine_bouncer/version'

Gem::Specification.new do |spec|
  spec.name          = "wine_bouncer"
  spec.version       = WineBouncer::VERSION
  spec.authors       = ["Antek Drzewiecki"]
  spec.email         = ["antek.drzewiecki@tass.nl"]
  spec.summary       = %q{A Ruby gem that allows Oauth2 protection with Doorkeeper for Grape Api's}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'grape'
  spec.add_runtime_dependency 'doorkeeper'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1.0"

end