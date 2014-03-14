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
  module Provider
    class OpenStackPublicIpService < PublicIpService
      interacts_with :os_neutron

      def create(connection, public_ip)
        ext_network_id = public_ip.provider_details.fetch(:ext_network_id)

        if public_ip.provider_details.key?(:fip_id)
          fip_id = public_ip.provider_details.fetch(:fip_id)
          return if connection.floating_ips.get(fip_id)
        end

        os_fip = connection.floating_ips.create(floating_network_id: ext_network_id)

        public_ip.ip_address = os_fip.floating_ip_address
        public_ip.provider_details[:fip_id] = os_fip.id
        public_ip.save
      end

      def delete(connection, public_ip)
        fip_id = public_ip.provider_details.fetch(:fip_id)
        if fip_id
          connection.delete_floating_ip(fip_id)
        end
      end

      def associate(connection, public_ip)
        instance = public_ip.instance

        fip_id = public_ip.provider_details.fetch(:fip_id)
        instance_id = instance.provider_details.fetch(:instance_id)

        os_fip = connection.floating_ips.get(fip_id)

        os_ports = connection.ports.all(device_id: instance_id)
        # TODO Be smarter about selection
        os_port = os_ports.first

        unless os_fip.port_id == os_port.id
          connection.associate_floating_ip(fip_id, os_port.id)
        end
      end

      def disassociate(connection, public_ip)
        fip_id = public_ip.provider_details.fetch(:fip_id)
        connection.disassociate_floating_ip(fip_id)
      end
    end # OpenStackPublicIpService
  end # Provider
end
