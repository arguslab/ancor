module V1
  class TasksController < ApplicationController
    def index
      @tasks = Task.all
      render json: @tasks, each_serializer: CompactTaskSerializer
    end
  end
end
