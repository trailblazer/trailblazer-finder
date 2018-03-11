require_relative 'spec_helper'
require_relative 'support/paging_shared_example'
require_relative 'support/sorting_shared_example'
require 'sequel'
Sequel::Model.plugin :timestamps
DB = Sequel.sqlite

DB.create_table :s_products do
  primary_key :id
  String :name
  String :slug
  Integer :s_category_id
  Integer :price
  DateTime :created_at
  DateTime :updated_at
end

DB.create_table :s_categories do
  primary_key :id
  String :title
  String :slug
  DateTime :created_at
  DateTime :updated_at
end

class SProduct < Sequel::Model
  many_to_one :s_category
end

class SCategory < Sequel::Model
  one_to_many :s_product
end
