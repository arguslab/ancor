module V1
  class EnvironmentsController < ApplicationController
    include EngineHelper

    # GET /environments
    def index
      @environments = Environment.all
      render json: @environments, each_serializer: CompactEnvironmentSerializer
    end

    # GET /environments/:id
    def show
      find_environment
      render json: @environment
    end

    # POST /environments
    def create
      @environment = Environment.new params
      @environment.save!

      render json: @environment, status: :created
    end

    # PUT /environments/:id
    def update
      find_environment

      if params[:commit]
        engine.commit(@environment)
        render nothing: true, status: 202
      else
        render nothing: true, status: 400
      end
    end

    # DELETE /environments/:id
    def destroy
      find_environment

      # TODO
    end

    # POST /environments/:id/plan
    def plan
      begin
        find_environment
      rescue Mongoid::Errors::DocumentNotFound
        @environment = Environment.create! slug: params[:environment_id]
      end

      unless request.content_type =~ /yaml/
        render nothing: true, status: 415
        return
      end

      spec = request.body.read
      builder = Ancor::Adaptor::YamlBuilder.new(@environment)

      begin
        # TODO Should validate before commit to prevent confusion
        # between client error (invalid spec) and server error (commit failure)

        builder.build(spec)
        builder.commit

        engine.plan(@environment)

        render nothing: true, status: 202
      rescue
        render nothing: true, status: 400
      end
    end

    def find_environment
      @environment = Environment.find_by slug: params[:id]
    end

  end
end
