# Author: Ian Unruh, Alexandru G. Bardas
# Copyright (C) 2013-2014 Argus Cybersecurity Lab, Kansas State University
#
# This file is part of ANCOR.
#
# ANCOR is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ANCOR is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with ANCOR.  If not, see <http://www.gnu.org/licenses/>.
module V1
  class InstancesController < ApplicationController

    include EngineHelper

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

    def update
      engine.replace_instance params[:id]
      render nothing: true, status: 200
    end

    def destroy
      engine.remove_instance params[:id]
      render nothing: true, status: 200
    end

    def replace_all
      engine.replace_all_instances params[:role]
      render nothing: true, status: 200
    end

  end
end
