# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'airity/version'

Gem::Specification.new do |spec|
  spec.name          = 'airity'
  spec.version       = Airity::Version
  spec.authors       = ['Rahul Horé']
  spec.email         = ['hore.rahul@gmail.com']
  spec.summary       = %q{Hangout on Air launcher}
  spec.description   = %q{Start a Google Hangout on Air from the command line}
  spec.homepage      = 'https://github.com/O-I/airity'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f|
                         f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'highline'
  spec.add_dependency 'capybara'
  spec.add_dependency 'selenium-webdriver'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
end