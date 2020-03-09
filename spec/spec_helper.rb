# frozen_string_literal: true

require "bundler/setup"
require "pry-byebug"
require "trailblazer/developer"
require "trailblazer/activity"
require "trailblazer/activity/testing"

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.include Trailblazer::Activity::Testing::Assertions
end

require "trailblazer/finder"
