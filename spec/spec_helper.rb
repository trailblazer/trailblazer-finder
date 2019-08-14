# frozen_string_literal: true

require "bundler/setup"
require "simplecov"
SimpleCov.start do
  add_group "Trailblazer-Finder", "lib"
  add_group "Tests", "spec"
end
require "pry-byebug"

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end

require "coveralls"
Coveralls.wear!

require "trailblazer/finder"
