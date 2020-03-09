# Really gotta clean this up, but can't be bothered right now
Trailblazer::Operation.instance_eval do
  def self.Finder(finder_class, action = nil, entity = nil)
    task = Trailblazer::Activity::TaskBuilder::Binary(Finder.new)
    injection = Trailblazer::Activity::TaskWrap::Inject::Defaults::Extension(
      :"finder.class"  => finder_class,
      :"finder.entity" => entity,
      :"finder.action" => action
    )

    {task: task, id: "finder.build", extensions: [injection]}
  end

  class Finder
    def call(ctx, options, **)
      builder                = Finder::Builder.new
      ctx[:finder]           = finder = builder.call(options, options[:params])
      ctx[:model]            = finder # Don't like it, but somehow it's needed if contracts are loaded
      ctx[:"result.finder"]  = Trailblazer::Operation::Result.new(!finder.nil?, {})


      ctx[:"result.finder"].success?
    end

    class Builder
      def call(options, params)
        finder_class  = options[:"finder.class"]
        entity        = options[:"finder.entity"]
        action        = options[:"finder.action"]
        action        = :all unless %i[all single].include?(action)

        send("#{action}!", finder_class, entity, params, options[:"finder.action"])
      end

      private

      def all!(finder_class, entity, params, *)
        finder_class.new(entity: entity, params: params)
      end

      def single!(finder_class, entity, params, *)
        apply_id(params)
        if entity.nil?
          finder_class.new(params: params).result.first
        else
          finder_class.new(entity: entity, params: params).result.first
        end
      end

      def apply_id(params)
        return if params[:id].nil?
        params[:id_eq] = params[:id]
      end
    end
  end
end
