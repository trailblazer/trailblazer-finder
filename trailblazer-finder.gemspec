lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'trailblazer/finder/version'

Gem::Specification.new do |spec|
  spec.name           = 'trailblazer-finder'
  spec.version        = Trailblazer::Finder::VERSION
  spec.date           = '2018-03-12'
  spec.description    = %q{Trailblazer Finder object DSL}
  spec.summary        = %q{Provides DSL for creating trailblazer based finder objects}
  spec.authors        = ["Nick Sutterer", "Marc Tich"]
  spec.email          = ["apotonick@gmail.com", "marc@mudsu.com"]
  spec.homepage       = 'http://trailblazer.to'
  spec.license        = 'MIT'
  spec.files          = `git ls-files`.split($/)
  spec.executables    = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files     = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths  = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'sequel'
  spec.add_development_dependency 'activerecord'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'will_paginate'
  spec.add_development_dependency 'kaminari'
  spec.add_development_dependency 'kaminari-activerecord'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'rspec-mocks', '~> 3.5'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'data_mapper'
  spec.add_development_dependency 'dm-sqlite-adapter'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'trailblazer', '>= 2.1.0.beta4'
  spec.add_development_dependency 'trailblazer-activity', '~> 0.4.3'
  spec.add_development_dependency 'rspec_junit_formatter'

  spec.required_ruby_version = '>= 2.2.0'
end
