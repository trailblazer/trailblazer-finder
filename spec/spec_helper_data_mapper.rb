require_relative 'spec_helper'
require_relative 'support/paging_shared_example'
require 'data_mapper'

DataMapper.setup(:default, 'sqlite::memory:')

class DProduct
  include DataMapper::Resource

  property :id,             Serial
  property :name,           String
  property :slug,           String
  property :d_category_id,  Integer
  property :price,          Integer
  property :created_at,     DateTime
  property :updated_at,     DateTime

  belongs_to :d_category
end

class DCategory
  include DataMapper::Resource

  property :id,             Serial
  property :title,          String
  property :slug,           String
  property :created_at,     DateTime
  property :updated_at,     DateTime

  has n, :d_product
end

DataMapper.finalize
require 'dm-migrations'
DataMapper.auto_migrate!
