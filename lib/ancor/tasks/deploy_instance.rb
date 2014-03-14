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
    class DeployInstance < BaseExecutor
      def perform(instance_id)
        instance = Instance.find instance_id

        ensure_task_chain [
          [:generate_cert, GeneratePuppetCertificate, instance_id],
          [:generate_bootstrap, GenerateInstanceBootstrap, instance_id],
          [:provision, ProvisionInstance, instance_id],
          [:push, PushConfiguration, instance_id],
        ]
      end
    end # DeployInstance
  end # Tasks
end
