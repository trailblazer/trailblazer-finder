# module Trailblazer
#   class Finder
#     module Adapters
#       module DataMapper
#         # Sequel - Sorting Adapter
#         module Sorting
#           def self.included(base)
#             base.extend Features::Sorting::ClassMethods
#           end
#
#           private
#
#           def sort_it(entity_type, sort_attribute, sort_direction)
#             case sort_direction
#             when 'asc', 'ascending'
#               entity_type.all(order: [sort_attribute.to_sym.asc])
#             when 'desc', 'descending'
#               entity_type.all(order: [sort_attribute.to_sym.desc])
#             end
#           end
#         end
#       end
#     end
#   end
# end
