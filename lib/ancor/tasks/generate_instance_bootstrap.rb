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
module Ancor
  module Tasks
    class GenerateInstanceBootstrap < BaseExecutor
      def perform(instance_id)
        instance = Instance.find instance_id
        certname = "#{instance.name}.#{instance.environment.slug}"

        config = Ancor.config

        template = ERB.new(
          File.read(File.expand_path('spec/config/ubuntu-precise.sh.erb', Rails.root))
        )
        mco_template = ERB.new(
          File.read(File.expand_path('spec/config/mcollective/server.cfg.erb', Rails.root))
        )

        mcollective_server_config = mco_template.result(binding)

        instance.provider_details[:user_data] = template.result(binding)

        instance.save!

        return true
      end
    end # GenerateInstanceBootstrap
  end # Tasks
end
