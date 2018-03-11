require 'spec_helper_data_mapper'

module Trailblazer
  class Finder
    module Adapters
      describe DataMapper do
        # it_behaves_like 'a base orm adapter'

        after do
          DProduct.all.destroy
        end

        def define_finder_class(&block)
          Class.new(Trailblazer::Finder) do
            class_eval(&block)
          end
        end

        def finder_class(&block) # rubocop:disable Metrics/MethodLength
          define_finder_class do
            adapters DataMapper

            entity_type { DProduct }

            filter_by :id
            filter_by :name
            filter_by :slug

            if block.nil?
              filter_by :value do |entity_type, value|
                entity_type.all(slug: value)
              end
            else
              class_eval(&block)
            end
          end
        end

        def finder_with_filter(key = nil, name = nil, &block)
          finder_class(&block).new filter: { key => name }
        end

        describe 'filter_by' do
          it 'has a default filter' do
            10.times { |i| DProduct.create name: "product_#{i}" }
            finder = finder_with_filter :name, 'product_2'

            expect(finder.results.first.name).to eq 'product_2'
          end

          it 'has another default filter' do
            10.times { |i| DProduct.create slug: "product_#{i}" }
            finder = finder_with_filter :value, 'product_2'

            expect(finder.results.first.slug).to eq 'product_2'
          end
        end

        it 'can use methods from the object' do
          2.times { |i| DProduct.create name: "product_#{i}" }
          finder1 = finder_with_filter :id, 1 do
            filter_by :id do |entity_type, value|
              some_instance_method(entity_type, value)
            end

            private

            def some_instance_method(entity_type, value)
              entity_type.all(id: value)
            end
          end

          expect(finder1.results.first.id).to eq 1
        end

        it 'can dispatch with instance methods' do
          2.times { |i| DProduct.create name: "product_#{i}" }
          finder = finder_with_filter :id, 3 do
            filter_by :id, with: :some_instance_method

            private

            def some_instance_method(entity_type, value)
              entity_type.all(id: value)
            end
          end

          expect(finder.results.first.id).to eq 3
        end

        describe 'filter_by attributes' do
          it 'accesses filter values' do
            finder = finder_with_filter :value, 1
            expect(finder.value).to eq 1
          end

          it 'returns default filter value if filter_by is not specified' do
            finder = finder_with_filter do
              filter_by :value, 1
            end
            expect(finder.value).to eq 1
          end

          it 'does not include invalid filters' do
            finder = finder_with_filter invalid: 'option'
            expect { finder.invalid }.to raise_error NoMethodError
          end
        end
      end
    end
  end
end
