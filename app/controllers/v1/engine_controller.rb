module V1
  class EngineController < ApplicationController

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

        engine.plan

        render nothing: true, status: 202
      rescue
        render nothing: true, status: 400
      end

    end

    def commit
      engine.commit
      render nothing: true, status: 202
    end

    private

    def engine
      @engine ||= Ancor::Adaptor::AdaptationEngine.new
    end

  end
end
