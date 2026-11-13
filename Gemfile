# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "debug", platform: :mri
gem "sqlite3"

gem "activerecord", "~> #{ENV['AR_VERSION'] || '8.0'}"

# The Trailblazer 3.0 line is not released to Rubygems yet.
gem "trailblazer-circuit", github: "trailblazer/trailblazer-circuit"
gem "trailblazer-core-utils", github: "trailblazer/trailblazer-core-utils"
gem "trailblazer-activity", github: "trailblazer/trailblazer-activity"
gem "trailblazer-activity-dsl", github: "trailblazer/trailblazer-activity-dsl"
gem "trailblazer-activity-variable-mapping", github: "trailblazer/trailblazer-activity-variable-mapping"
gem "trailblazer-developer", github: "trailblazer/trailblazer-developer"
gem "trailblazer-operation", github: "trailblazer/trailblazer-operation"
