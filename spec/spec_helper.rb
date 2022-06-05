# frozen_string_literal: true

require "bundler/setup"
require "trailblazer/developer"
require "trailblazer/activity"
require "trailblazer/activity/testing"

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.include Trailblazer::Activity::Testing::Assertions
  config.disable_monkey_patching!
end

require "trailblazer/finder"
