module V1
  class TasksController < ApplicationController
    def index
      @tasks = Task.all.asc(:updated_at)
      render json: @tasks, each_serializer: CompactTaskSerializer
    end
  end
end
