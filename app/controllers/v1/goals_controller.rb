module V1
  class GoalsController < ApplicationController
    def index
      @goals = Goal.all
      render json: @goals, each_serializer: CompactGoalSerializer
    end
  end
end
