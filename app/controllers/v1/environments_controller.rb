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

      engine.destroy(@environment)

      render nothing: true, status: 200
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
      #rescue
      #  render nothing: true, status: 400
      end
    end

    def find_environment
      @environment = Environment.find_by slug: params[:id]
    end

  end
end
