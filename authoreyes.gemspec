# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'authoreyes/version'

Gem::Specification.new do |spec|
  spec.name          = 'authoreyes'
  spec.version       = Authoreyes::VERSION
  spec.authors       = ['Tektite Software', 'Xavier Bick']
  spec.email         = ['fxb9500@gmail.com']

  spec.summary       = 'A modern authorization plugin for Rails.'
  spec.description   = 'A powerful, modern authorization plugin for Ruby on
                        Rails featuring a declarative DSL for centralized
                        authorization roles.
                        Based on Declarative Authorization.'
  spec.homepage      = 'https://www.github.com/tektite-software/authoreyes'
  spec.license       = 'MIT'


  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
