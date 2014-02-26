module V1
  class EngineController < ApplicationController

    # TODO Global state
    class << self
      def with_engine
        @mutex.synchronize { yield @engine }
      end
      def setup
        @mutex = Mutex.new
        @engine = Ancor::Adaptor::AdaptationEngine.new
      end
    end

    def plan
      unless request.content_type =~ /yaml/
        render nothing: true, status: 415
        return
      end

      spec = request.body.read
      builder = Ancor::Adaptor::YamlBuilder.new

      begin
        # TODO Should validate before commit to prevent confusion
        # between client error (invalid spec) and server error (commit failure)

        builder.build(spec)
        builder.commit

        # TODO Global state
        EngineController.with_engine do |engine|
          engine.plan
        end

        render nothing: true, status: 202
      rescue
        render nothing: true, status: 400
      end

    end

    def deploy
      EngineController.with_engine do |engine|
        engine.deploy
      end

      render nothing: true, status: 202
    end

  end

  EngineController.setup
end
