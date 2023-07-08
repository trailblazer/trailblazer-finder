# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "debug", platform: :mri
platforms :jruby do
  gem "activerecord-jdbcsqlite3-adapter", ">= 70.1"
  gem "jdbc-sqlite3", "<3.42" # version 3.42.0 is broken
end
gem "sqlite3", platform: [:mri, :truffleruby]

# Had to add this for a bit, since none of the latest changes have been pushed to gems yet
# gem "trailblazer", github: "trailblazer/trailblazer"
# gem "trailblazer-operation", github: "trailblazer/trailblazer-operation"
# gem "trailblazer-activity", github: "trailblazer/trailblazer-activity"
# gem "trailblazer-macro", github: "trailblazer/trailblazer-macro"
# gem "trailblazer-macro-contract", github: "trailblazer/trailblazer-macro-contract"
