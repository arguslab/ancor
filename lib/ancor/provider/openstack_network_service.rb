module Ancor
  module Provider
    class OpenStackNetworkService < NetworkService
      # @param [Fog::Network::OpenStack] connection
      # @param [Network] network
      # @return [undefined]
      def create(connection, network)
        # TODO Lock the network for this operation

        provision_network connection, network
        provision_subnet  connection, network
        attach_router_interface connection, network
      end

      # @param [Fog::Network::OpenStack] connection
      # @param [Network] network
      # @return [undefined]
      def delete(connection, network)
        # TODO Lock the network for this operation

        # Identify network
        network_id = network.provider_details["network_id"]

        os_network = conection.networks.find do |p|
          p.network_id == network_id
        end

        # Delete interface(s) from router
        router_id = network.provider_details["router_id"]
        subnet_id = network.provider_details["subnet_id"]

        attempt do
          connection.remove_router_interface router_id, subnet_id
        end

        os_network.destroy

      end

      private

      # @param [Fog::Network::OpenStack] connection
      # @param [Network] Network
      # @return [undefined]
      def provision_network(connection, network)
        options = {
          name: network.name
        }

        provider_network = connection.networks.create options

        network.provider_details["network_id"] = provider_network.id
        network.save
      end

      # @param [Fog::Network::OpenStack] connection
      # @param [Network] network
      # @return [undefined]
      def provision_subnet(connection, network)
        options = {
          network_id: network.provider_details["network_id"],
          cidr: network.cidr,
          ip_version: network.ip_version,
        }

        provider_subnet = attempt do
          connection.subnets.create options
        end

        network.provider_details["subnet_id"] = provider_subnet.id
        network.save
      end

      # @param [Fog::Network::OpenStack] connection
      # @param [Network] network
      # @return [undefined]
      def attach_router_interface(connection, network)
        router_id = network.provider_details["router_id"]
        subnet_id = network.provider_details["subnet_id"]

        attempt do
          connection.add_router_interface router_id, subnet_id
        end
      end

    end # OpenStackNetworkService
  end
end
