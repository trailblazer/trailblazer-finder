require_relative "spec_helper"
# require_relative 'support/paging_shared_example'
require "active_record"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

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

class Product < ActiveRecord::Base
  belongs_to :category
end

class Category < ActiveRecord::Base
end

module ActiveRecord
  class Base
    def self.reset_pk_sequence
      case ActiveRecord::Base.connection.adapter_name
        when "SQLite"
          new_max = maximum(primary_key) || 0
          update_seq_sql = "update sqlite_sequence set seq = #{new_max} where name = '#{table_name}';"
          ActiveRecord::Base.connection.execute(update_seq_sql)
        else
          exit(1)
      end
    end
  end
end
