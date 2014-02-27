module V1
  class RolesController < ApplicationController
    def index
      @roles = Role.all
      render json: @roles, each_serializer: CompactRoleSerializer
    end
  end
end
