# frozen_string_literal: true

require_relative "lib/trailblazer/finder/version"

Gem::Specification.new do |spec|
  spec.name           = "trailblazer-finder"
  spec.version        = Trailblazer::Finder::VERSION
  spec.description    = "Trailblazer Finder Objects"
  spec.summary        = "Trailblazer based finder objects. It is designed to be used on its own as a separate gem. It was influenced by popular Ransack gem, but in addition to ActiveRecord, it can be used with Sequel, Hash objects, and RomRB."
  spec.authors        = ["Nick Sutterer", "Marc Tich", "Abdelkader Boudih"]
  spec.email          = %w[apotonick@gmail.com marc@mudsu.com terminale@gmail.com]
  spec.homepage       = "https://trailblazer.to"
  spec.license        = "LGPL-3.0"
  spec.files          = Dir.glob("lib/**/*")
  spec.require_paths = ["lib"]

  spec.metadata['source_code_uri'] = 'https://github.com/trailblazer/trailblazer-finder'
  spec.metadata['changelog_uri'] = 'https://github.com/trailblazer/trailblazer-finder/blob/master/CHANGELOG.md'

  spec.add_dependency "dry-types", ">= 1.0.0"
  spec.add_dependency "trailblazer-macro", ">= 2.1.15"
  spec.add_dependency "trailblazer-activity", ">= 0.13.0"
  spec.add_dependency "trailblazer-activity-dsl-linear", ">= 1.2.5"
  spec.add_dependency "zeitwerk", ">= 2.6.0"

  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "kaminari"
  spec.add_development_dependency "kaminari-activerecord"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "maxitest"
  spec.add_development_dependency "sequel"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "trailblazer", "~> 2.1.0"
  spec.add_development_dependency "trailblazer-developer"
  spec.add_development_dependency "will_paginate"
  spec.add_development_dependency 'minitest-trailblazer'

  spec.required_ruby_version = ">= 2.5.0"
  spec.metadata = {"rubygems_mfa_required" => "true"}
end
