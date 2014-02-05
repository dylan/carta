# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'carta/version'

Gem::Specification.new do |spec|
  spec.name          = 'carta'
  spec.version       = Carta::VERSION
  spec.authors       = ['Dylan Wreggelsworth']
  spec.email         = ['dylan@bvrgroup.us']
  spec.summary       = 'An ebook generator.'
  spec.description   = 'Generates a basic ebook project directory and renders it.'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler',    '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_runtime_dependency     'uuid',       '>= 0'
  spec.add_runtime_dependency     'rubyzip',    '~> 1.0.0'
  spec.add_runtime_dependency     'mime-types', '~> 2.1'
  spec.add_runtime_dependency     'thor',       '= 0.18.1'
  spec.add_runtime_dependency     'redcarpet',  '= 3.0.0'
end
