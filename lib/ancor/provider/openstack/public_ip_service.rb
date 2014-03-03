module Ancor
  module Provider
    class OpenStackPublicIpService < PublicIpService
      interacts_with :os_neutron

      def create(connection, public_ip)
        ext_network_id = public_ip.provider_details.fetch(:ext_network_ip)

        # TODO Check if PublicIp already allocated
        os_fip = connection.floating_ips.create(ext_network_id)

        public_ip.ip_address = os_fip.floating_ip_address
        public_ip.provider_details[:fip_id] = os_fip.id
        public_ip.save
      end

      def delete(connection, public_ip)
        fip_id = public_ip.provider_details.fetch(:fip_id)

        connection.delete_floating_ip(fip_id)

        public_ip.destroy
      end

      def associate(connection, public_ip, instance)
        fip_id = public_ip.provider_details.fetch(:fip_id)
        instance_id = instance.provider_details.fetch(:instance_id)

        os_ports = connection.ports.all(device_id: instance_id)
        # TODO Be smarter about selection
        os_port = os_ports.first

        connection.associate_floating_ip(fip_id, os_port.id)
      end

      def disassociate(connection, public_ip)
        fip_id = public_ip.provider_details.fetch(:fip_id)
        connection.disassociate_floating_ip(fip_id)
      end
    end # PublicIpService
  end # Provider
end
