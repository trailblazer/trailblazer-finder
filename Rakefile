# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--format documentation --format RspecJunitFormatter --out test-reports/spec.xml"
end
RSpec::Core::RakeTask.new(:tests) do |t|
  t.rspec_opts = "--format progress --format documentation"
end
RSpec::Core::RakeTask.new(:spec_report) do |t|
  t.rspec_opts = "--format html --out reports/rspec_results.html"
end

RuboCop::RakeTask.new(:rubocop)

desc "Build the gem"
task :gem do
  `gem build trailblazer-finder.gemspec`
end

desc "Running Tests"
task default: %i[spec]
