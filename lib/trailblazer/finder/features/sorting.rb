module Trailblazer
  class Finder
    module Features
      module Sorting
        def self.included(base)
          base.extend ClassMethods
          base.instance_eval do
            filter_by :sort do |entity_type, value|
              next sort_it(entity_type, [sort_orders(sort_attribute(value), sort_direction(value))]) if value.nil?
              sort_attributes = value.split(',')
              sorters = []
              sort_attributes.each do |sort_attr|
                sorters << sort_orders(sort_attribute(sort_attr), sort_direction(sort_attr))
              end
              sort_it(entity_type, sorters)
            end
          end
        end

        def sort?(attribute)
          sort.include?(attribute.to_s)
        end

        def sort_direction_for(attribute)
          return 'asc' if !sort.nil? && sort.include?("#{attribute} asc")
          'desc'
        end

        def reverse_sort_direction_for(attribute)
          return 'desc' if sort_direction_for(attribute) == 'asc'
          'asc'
        end

        def sort_params_for(attribute, options = {})
          options['sort'] = if sort.nil?
                              "#{attribute} #{sort_direction_for(attribute)}"
                            elsif sort.include?(attribute.to_s)
                              sort
                            else
                              "#{attribute} #{sort_direction_for(attribute)}"
                            end
          params options
        end

        def new_sort_params_for(attribute, options = {})
          options['sort'] = "#{attribute} #{sort_direction_for(attribute)}"
          params options
        end

        def add_sort_params_for(attribute, options = {})
          options['sort'] = if sort.nil?
                              "#{attribute} #{sort_direction_for(attribute)}"
                            elsif sort.include?(attribute.to_s)
                              sort.gsub(/#{attribute} #{sort_direction_for(attribute)}/, "#{attribute} #{reverse_sort_direction_for(attribute)}")
                            else
                              "#{sort}, #{attribute} #{sort_direction_for(attribute)}"
                            end
          params options
        end

        private

        # ORM Adapters will overwite this method
        def sort_it(entity_type, sort_attributes)
          entity_type.sort do |this, that|
            sort_attributes.reduce(0) do |diff, order|
              next diff if diff != 0 # this and that have differed at an earlier order entry
              key, direction = order
              # deal with nil cases
              next  0 if this[key].nil? && that[key].nil?
              next  1 if this[key].nil?
              next -1 if that[key].nil?
              # do the actual comparison
              comparison = this[key] <=> that[key]
              comparison * direction
            end
          end
        end

        # ORM Adapters will overwite this method
        def sort_orders(sort_attr, sort_dir)
          [sort_attr.to_sym, (sort_dir.to_sym == :asc ? 1 : -1)]
        end

        def sort_attribute(attribute)
          result = Utils::Extra.ensure_included attribute.to_s.split(' ', 2).first, self.class.sort_attributes
          result
        end

        def sort_direction(attribute)
          return Utils::Extra.ensure_included attribute.to_s.split(' ', 2).last, %w[desc asc] unless attribute.nil?
          'desc'
        end

        module ClassMethods
          attr_accessor :sorted_attributes
          def sortable_by(*attributes)
            config[:sort_attributes] = attributes.map(&:to_s)
          end

          def sort_attributes
            config[:sort_attributes] ||= []
          end
        end
      end
    end
  end
end
