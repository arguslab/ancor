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
    class GeneratePuppetCertificate < BaseExecutor
      include Conductor::ClientUtil

      def perform(instance_id)
        instance = Instance.find instance_id

        ca_client = rpc_client :puppetca
        results = client_sync {
          ca_client.generate certname: "#{instance.name}.#{instance.environment.slug}"
        }

        data = results[0].results[:data]

        # TODO Check output

        instance.cmt_details = data.except(:out) # No need to store the output
        instance.save!

        true
      end
    end # GeneratePuppetCertificate
  end # Tasks
end
