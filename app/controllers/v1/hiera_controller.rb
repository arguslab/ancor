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
  class HieraController < ApplicationController
    def show
      certname = params[:certname]

      hostname = certname.split('.')[0]
      instance = Instance.where(name: hostname).first

      if instance
        data = {
          exports: Hash[instance.channel_selections.map { |s| [s.slug, s.to_hash] }],
          imports: import_selector.select(instance),
          proxy_url: import_proxy,
          instances: instances,
          classes: [
            instance.scenario.profile
          ],
        }

        render json: data, status: 200
      else
        render nothing: true, status: 404
      end
    end

    private

    def instances
      result = {}

      Instance.all.each do |instance|
        result[instance.name] = {
          ip_address: instance.interfaces.first.ip_address
        }
      end

      result
    end

    def import_selector
      @import_selector ||= Ancor::Adaptor::ImportSelector.instance
    end

    def import_proxy
      config = Ancor.config
      if config[:proxy] and config[:proxy][:host] and config[:proxy][:port]
        proxy = "http://#{config[:proxy][:host]}:#{config[:proxy][:port]}/"
      else
        proxy = ""
      end
    end
  end
end
