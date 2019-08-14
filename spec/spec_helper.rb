# frozen_string_literal: true

require "bundler/setup"
require "pry-byebug"

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end

require "trailblazer/finder"
