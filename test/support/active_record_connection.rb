# frozen_string_literal: true

require 'active_record'

puts "Using RUBY_ENGINE=#{RUBY_ENGINE} with ActiveRecord #{ActiveRecord.gem_version}"
database_adapter = RUBY_ENGINE == 'jruby' ? 'jdbcsqlite3' : 'sqlite3'
puts "Using #{database_adapter} with RUBY_ENGINE=#{RUBY_ENGINE}"
ActiveRecord::Base.establish_connection adapter: database_adapter, database: ':memory:'

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :products, force: true do |t|
    t.string :name
    t.string :slug
    t.integer :category_id
    t.integer :price

    t.timestamps null: true
  end

  create_table :categories, force: true do |t|
    t.string :title
    t.string :slug

    t.timestamps null: true
  end
end

module ActiveRecord
  class Base
    def self.reset_pk_sequence
      case ActiveRecord::Base.connection.adapter_name
      when 'SQLite'
        new_max = maximum(primary_key) || 0
        update_seq_sql = "update sqlite_sequence set seq = #{new_max} where name = '#{table_name}';"
        ActiveRecord::Base.connection.execute(update_seq_sql)
      else
        exit(1)
      end
    end
  end
end
