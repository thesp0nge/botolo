# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'botolo/version'

Gem::Specification.new do |spec|
  spec.name          = "botolo"
  spec.version       = Botolo::VERSION
  spec.authors       = ["Paolo Perego"]
  spec.email         = ["thesp0nge@gmail.com"]
  spec.description   = %q{botolo is a bot engine written in ruby}
  spec.summary       = %q{botolo is a bot engine written in ruby}
  spec.homepage      = "http://codesake.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency "twitter"
  spec.add_dependency "codesake_commons"
end
