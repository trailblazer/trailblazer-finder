require 'spec_helper_data_mapper'

module Trailblazer
  class Finder
    module Adapters
      module DataMapper
        describe Paging do
          it_behaves_like 'a paging feature'

          after do
            DProduct.all.destroy
          end

          def define_finder_class(&block)
            Class.new do
              include Trailblazer::Finder::Base
              include Trailblazer::Finder::Features::Paging
              include Trailblazer::Finder::Adapters::DataMapper

              instance_eval(&block) if block_given?
            end
          end

          def finder_class
            define_finder_class do
              entity_type { DProduct }

              per_page 2

              min_per_page 2
              max_per_page 10
            end
          end

          def finder_with_page(page = nil, per_page = nil)
            finder_class.new page: page, per_page: per_page
          end

          it 'can be inherited' do
            child_class = Class.new(finder_class)
            expect(child_class.new.per_page).to eq 2
          end

          describe '#results' do
            it 'paginates results' do
              6.times { |i| DProduct.create name: "product_#{i}" }
              finder = finder_with_page 2, 2

              expect(finder.results.map(&:name)).to eq %w[product_2 product_3]
            end
          end

          describe '#count' do
            it 'gives the real count' do
              10.times { |i| DProduct.create name: "product_#{i}" }
              finder = finder_with_page 1
              expect(finder.count).to eq 10
            end
          end
        end
      end
    end
  end
end
