# frozen_string_literal: true

require 'bundler/setup'
require 'trailblazer/developer'
require 'trailblazer/activity'
require 'trailblazer/activity/testing'
require 'trailblazer/finder'
require 'minitest-trailblazer'
require 'minitest/trailblazer_spec'

require 'maxitest/autorun'

Minitest::TrailblazerTest.class_eval do
  include Minitest::Trailblazer::AssertionsOverride
end

Minitest::TrailblazerSpec.class_eval do
  include Minitest::Trailblazer::AssertionsOverride
end
