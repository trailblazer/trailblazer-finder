# frozen_string_literal: true

require_relative 'active_record_connection'
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class Product < ApplicationRecord
  belongs_to :category
end

class Category < ApplicationRecord
  has_many :products
end
