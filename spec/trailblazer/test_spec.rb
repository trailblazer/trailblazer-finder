# require 'spec_helper_active_record'
#
#         class TestFinder < Trailblazer::Finder
#             features Predicates
#             adapters ActiveRecord, FriendlyId
#
#             entity_type { Product }
#
#             predicates_for :name, :price, :created_at
#
#             filter_by(:category) { |entity_type, _| entity_type.joins(:category) }
#           end
#
#         def finder_with_predicate(filter = nil, value = nil, filters = {})
#           TestFinder.new filter: { filter => value }.merge(filters)
#         end
#
#         describe 'eqauls' do
#           before do
#             Product.delete_all
#             10.times do |i|
#               Product.create name: "product_#{i}", price: "1#{i}"
#               Product.create name: "product_4", price: "1#{1}" if i == 5
#             end
#           end
#
#           it 'it finds single row with name equal to product_5' do
#             finder = finder_with_predicate 'name_eq', 'product_5'
#             expect(finder.results.map(&:price)).to eq [15]
#           end
#
#           it 'it finds multiple rows with name equal to product_4' do
#             finder = finder_with_predicate 'name_eq', 'product_4'
#             expect(finder.results.map(&:price)).to eq [14, 11]
#           end
#
#           it 'it finds rows with name not equal to product_5' do
#             finder = finder_with_predicate 'name_not_eq', 'product_4'
#             expect(finder.results.map(&:name)).to eq ["product_0", "product_1", "product_2", "product_3", "product_5", "product_6", "product_7", "product_8", "product_9"]
#           end
#         end
