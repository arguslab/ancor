module V1
  class InstancesController < ApplicationController
    def index
      @instances = Instance.all
      render json: @instances, each_serializer: CompactInstanceSerializer
    end

    def show
      @instance = Instance.find params[:id]
      render json: @instance
    end

    def create
      @instance = engine.add_instance params[:role]
      render json: @instance
    end

    def destory
      engine.remove_instance params[:id]
    end

    private

    def engine
      @engine ||= Ancor::Adaptor::AdaptationEngine.new
    end

  end
end
