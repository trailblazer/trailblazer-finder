lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'trailblazer/finder/version'

Gem::Specification.new do |spec|
  spec.name           = 'trailblazer-finder'
  spec.version        = Trailblazer::Finder::VERSION
  spec.description    = 'Trailblazer Finder object DSL'
  spec.summary        = 'Provides DSL for creating trailblazer based finder objects. It is designed to be used on its own as a separate gem.  It was influenced by popular Ransack gem, but in addition to ActiveRecord, it can be used with DataMapper or Sequel. It also integrates with Kaminari or Will Paginate, as well as FriendlyId'
  spec.authors        = ['Nick Sutterer', 'Marc Tich']
  spec.email          = ['apotonick@gmail.com', 'marc@mudsu.com']
  spec.homepage       = 'http://trailblazer.to'
  spec.license        = "LGPL-3.0"
  spec.files          = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.test_files     = spec.files.grep(%r{^(test)/})
  spec.require_paths  = ['lib']

  spec.add_development_dependency 'activerecord'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'data_mapper'
  spec.add_development_dependency 'dm-sqlite-adapter'
  spec.add_development_dependency 'kaminari'
  spec.add_development_dependency 'kaminari-activerecord'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'rspec-mocks', '~> 3.5'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'sequel'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'trailblazer', '>= 2.1.0.beta4'
  spec.add_development_dependency 'will_paginate'

  spec.required_ruby_version = '>= 2.2.0'
end
