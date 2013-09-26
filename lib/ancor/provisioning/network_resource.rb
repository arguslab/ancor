module Ancor
  module Provisioning
    class NetworkResource < Resource
      map_document Network

      def exists?
        document && :present == document.status
      end

      def create
        create_network
        create_subnet
        attach_to_router

        update_status :present
      end

      def destroy
        detach_from_router
        destroy_subnet
        destroy_network

        update_status :absent
      end

      def update
        # TODO This will probably have to raise an exception
        # In most cases, you would have to replace the subnet or entire network
      end

      private

      def update_status(status)
        document.status = status
        document.save
      end

      def create_network
        options = {
          name: document.name
        }

        os_network = provider.networks.create options

        document.provider['network_id'] = os_network.id
        document.save
      end

      def create_subnet
        options = {
          network_id: document.provider['network_id'],
          cidr: document.cidr,
          ip_version: document.ip_version,
        }

        # DNS nameservers are optional
        dns_nameservers = document.provider['dns_nameservers']
        if dns_nameservers
          options[:dns_nameservers] = dns_nameservers
        end

        os_subnet = attempt do
          provider.subnets.create options
        end

        document.provider['subnet_id'] = os_subnet.id
        document.save
      end

      def attach_to_router
        router_id = document.provider['router_id']
        subnet_id = document.provider['subnet_id']

        attempt do
          provider.add_router_interface router_id, subnet_id
        end
      end

      def detach_from_router
        router_id = document.provider['router_id']
        subnet_id = document.provider['subnet_id']

        provider.remove_router_interface router_id, subnet_id
      end

      def destroy_subnet
        subnet_id = document.provider['subnet_id']

        attempt do
          provider.delete_subnet subnet_id
        end
      end

      def destroy_network
        network_id = document.provider['network_id']

        attempt do
          provider.delete_network network_id
        end
      end

      def provider
        Provider.network
      end
    end # Resource
  end # Provisioning
end
