# frozen_string_literal: true

require 'forwardable'
require 'dry-types'
require 'ostruct'
require 'zeitwerk'
require 'trailblazer/operation'
require 'trailblazer/macro'

loader = Zeitwerk::Loader.for_gem_extension(Trailblazer)
adapters = "#{__dir__}/finder/adapters"
loader.do_not_eager_load(adapters)
loader.setup

module Trailblazer
  class Finder
    module Types
      include Dry.Types(default: :nominal)
    end
    EXT_ORM_ADAPTERS = Types::Strict::String.enum('ActiveRecord', 'Sequel')
    ORM_ADAPTERS = EXT_ORM_ADAPTERS | Types::Strict::String.enum('Basic')
    PAGING_ADAPTERS = Types::Strict::String.enum('Kaminari', 'WillPaginate')

    include Base
  end
end

loader.eager_load
