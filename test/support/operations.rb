# frozen_string_literal: true

module Product::Finders
  class FinderNoEntity < Trailblazer::Finder
    adapter 'ActiveRecord'

    property :id, type: Types::Integer
    property :name, type: Types::String, sortable: true
    filter_by :escaped_name, with: :apply_escaped_name

    def apply_escaped_name(entity, _attribute, value)
      return if value.blank?

      entity.where 'lower(name) LIKE ?', "%#{value.downcase}%"
    end
  end

  class FinderWithEntity < Trailblazer::Finder
    adapter 'ActiveRecord'

    entity { Product }

    property :id, type: Types::Integer
    property :name, type: Types::String, sortable: true
    filter_by :escaped_name, with: :apply_escaped_name

    def apply_escaped_name(entity, _attribute, value)
      return if value.blank?

      entity.where 'lower(name) LIKE ?', "%#{value.downcase}%"
    end
  end
end

module Product::Operations
  class Index < Trailblazer::Operation
    step Finder(Product::Finders::FinderNoEntity, :all, Product)
  end

  class Show < Trailblazer::Operation
    step Finder(Product::Finders::FinderNoEntity, :single, Product)
  end

  class IndexNoEntity < Trailblazer::Operation
    step Finder(Product::Finders::FinderWithEntity, :all)
  end

  class ShowNoEntity < Trailblazer::Operation
    step Finder(Product::Finders::FinderWithEntity, :single)
  end
end
