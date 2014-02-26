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
  end
end
