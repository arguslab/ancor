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
    class DeleteNetwork < BaseExecutor
      def perform(network_id)
        network = Network.find network_id
        locator = Provider::ServiceLocator.instance

        endpoint = network.provider_endpoint

        connection = locator.connection(endpoint)
        service = locator.service(endpoint.type, Provider::NetworkService)
        service.delete(connection, network)

        network.destroy

        return true
      end
    end # DeleteNetwork
  end # Tasks
end
