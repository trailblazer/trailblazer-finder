# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "trailblazer/finder/version"

Gem::Specification.new do |spec|
  spec.name           = "trailblazer-finder"
  spec.version        = Trailblazer::Finder::VERSION
  spec.description    = "Trailblazer Finder Objects"
  spec.summary        = "Trailblazer based finder objects. It is designed to be used on its own as a separate gem. It was influenced by popular Ransack gem, but in addition to ActiveRecord, it can be used with Sequel, Hash objects, and RomRB."
  spec.authors        = ["Nick Sutterer", "Marc Tich", "Abdelkader Boudih"]
  spec.email          = ["apotonick@gmail.com", "marc@mudsu.com", "terminale@gmail.com"]
  spec.homepage       = "http://trailblazer.to"
  spec.license        = "LGPL-3.0"
  spec.files          = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.test_files     = spec.files.grep(%r{^(test)/})
  spec.require_paths  = ["lib"]

  spec.add_dependency "dry-types"
  spec.add_dependency "trailblazer-activity", ">= 0.10.0"

  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "kaminari"
  spec.add_development_dependency "kaminari-activerecord"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "rspec-mocks", "~> 3.5"
  spec.add_development_dependency "rspec_junit_formatter"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "sequel"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "trailblazer", "~> 2.1.0"
  spec.add_development_dependency "will_paginate"
  spec.add_development_dependency "trailblazer-developer"

  spec.required_ruby_version = ">= 2.3.8"
end
