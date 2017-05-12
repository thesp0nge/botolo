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
  spec.summary       = %q{botolo is a bot engine written in ruby. With botolo
    you can focus on writing a set of actions your bot will execute every
    amount of seconds, minutes or whatever and implement those actions. The
    part of executing them and putting babies to sleep will be up to botolo.}
  spec.homepage      = "https://codiceinsicuro.it"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency "twitter", "~> 5.11.0"
  spec.add_dependency "logger-colors"
  spec.add_dependency "data_mapper"
  spec.add_dependency "dm-sqlite-adapter"
end
