
# Really gotta clean this up, but can't be bothered right now
module Trailblazer
  class Operation
    def self.Finder(finder_class, action = nil, entity_type = nil)
      task = Trailblazer::Activity::TaskBuilder::Binary(Finder.new)

      extension = Trailblazer::Activity::TaskWrap::Merge.new(
        Wrap::Inject::Defaults(
          'finder.class'        => finder_class,
          'finder.entity_type'  => entity_type,
          'finder.action'       => action
        )
      )

      { task: task, id: 'finder.build', Trailblazer::Activity::DSL::Extension.new(extension) => true}
    end

    class Finder
      def call(options, params:, **)
        builder                   = Finder::Builder.new
        options[:finder]          = finder = builder.call(options, params)
        options[:model]           = finder # Don't like it, but somehow it's needed if contracts are loaded
        options['result.finder']  = result = Result.new(!finder.nil?, {})

        result.success?
      end

      class Builder
        def call(options, params)
          finder_class  = options['finder.class']
          entity_type   = options['finder.entity_type'] || nil
          action        = options['finder.action'] || :all
          action        = :all unless %i[all single].include?(action)

          send("#{action}!", finder_class, entity_type, params, options['finder.action'])
        end

        private

        def all!(finder_class, entity_type, params, *)
          finder_class.new(entity_type: entity_type, filter: params[:f], page: params[:page], per_page: params[:per_page])
        end

        def single!(finder_class, entity_type, params, *)
          apply_id(params)
          if entity_type.nil?
            finder_class.new(filter: params[:f], page: params[:page], per_page: params[:per_page]).results.first
          else
            finder_class.new(entity_type: entity_type, filter: params[:f]).results.first
          end
        end

        def apply_id(params)
          return if params[:id].nil?
          params[:f] = {} unless params.key?('f')
          params[:f][:id] = params[:id] unless params[:f].key?('id')
        end
      end
    end
  end
end
