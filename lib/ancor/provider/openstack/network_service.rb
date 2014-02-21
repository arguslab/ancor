module Ancor
  module Provider
    # TODO Can descriptions or notes be added to networks/subnets? If so, set them
    # to 'Maintained by ANCOR'
    class OpenStackNetworkService < NetworkService
      interacts_with :os_neutron

      # @param [Fog::Network::OpenStack] connection
      # @param [Network] network
      # @return [undefined]
      def create(connection, network)
        # TODO Lock the network for this operation

        network_id = provision_network(connection, network)
        subnet_id = provision_subnet(connection, network)
        attach_router_interface(connection, network)
      end

      # @param [Fog::Network::OpenStack] connection
      # @param [Network] network
      # @return [undefined]
      def delete(connection, network)
        # TODO Lock the network for this operation

        # Identify network
        network_id = network.provider_details[:network_id]

        # TODO You can look up network by ID directly. However, find can be used
        # in the case where network ID was not persisted to model and you need to find
        # the network by name

        # Delete interface(s) from router
        router_id = network.provider_details[:router_id]
        subnet_id = network.provider_details[:subnet_id]

        attempt do
          connection.remove_router_interface router_id, subnet_id
        end

        connection.delete_subnet subnet_id

        os_network = connection.networks.get network_id

        if os_network.subnets.empty?
          os_network.destroy
        else
          logger.info "Network #{network_id} has other subnets"
        end
      end

      private

      # @param [Fog::Network::OpenStack] connection
      # @param [Network] Network
      # @return [String] Identifier of the network on OpenStack
      def provision_network(connection, network)
        options = {
          name: network.name
        }

        os_network = connection.networks.create options

        network.provider_details[:network_id] = os_network.id
        network.save

        os_network.id
      end

      # @param [Fog::Network::OpenStack] connection
      # @param [Network] network
      # @return [String] Identifier of the subnet on OpenStack
      def provision_subnet(connection, network)
        options = {
          network_id: network.provider_details[:network_id],
          cidr: network.cidr,
          ip_version: network.ip_version,
          dns_nameservers: network.dns_nameservers
        }

        os_subnet = attempt do
          connection.subnets.create options
        end

        network.provider_details[:subnet_id] = os_subnet.id
        network.save

        os_subnet.id
      end

      # @param [Fog::Network::OpenStack] connection
      # @param [Network] network
      # @return [undefined]
      def attach_router_interface(connection, network)
        router_id = network.provider_details[:router_id]
        subnet_id = network.provider_details[:subnet_id]

        attempt do
          connection.add_router_interface router_id, subnet_id
        end
      end
    end # OpenStackNetworkService
  end # Provider
end
