module Ancor
  module Provisioning
    class InstanceResource < Resource
      map_document Instance

      def exists?
        document && :present == document.status
      end

      def create
        create_instance
        update_status :present
      end

      def destroy
        destroy_instance
        destroy_security_group

        update_status :absent
      end

      def update
        # TODO Implement me
      end

      private

      def update_status(status)
        document.status = status
        document.save
      end

      def create_security_group
        options = {
          name: document.name,
          description: 'Maintained by Ancor'
        }

        provider.security_groups.create options
      end

      def destroy_security_group
        # TODO Implement me
      end

      def create_instance
        nics = build_nic_specification
        security_group = create_security_group
        user_data = load_user_data

        options = {
          name: document.name,
          flavor_ref: document.provider['flavor_id'],
          image_ref: document.provider['image_id'],
          nics: nics,
          security_groups: [security_group],
          user_data: user_data
        }

        os_instance = provider.servers.create options
        # TODO This should not be hard-coded
        wait_until 240 do
          os_instance.reload.ready?
        end

        document.provider['instance_id'] = os_instance.id
        document.save
      end

      def destroy_instance
        # TODO Implement me
      end

      def build_nic_specification
        document.interfaces.map { |interface|
          network = interface.network
          fixed_ip = interface.ip_address

          specification = {
            net_id: network.provider['network_id'],
            # this is not limited to IPv4, Fog is just weird
            v4_fixed_ip: fixed_ip
          }

          # Which is it Fog? String or symbol keys?
          specification.stringify_keys
        }
      end

      def load_user_data
        object_id = document.provider['user_data_object_id']
        if object_id
          object_store.get object_id
        end
      end

      def provider
        Provider.instance
      end

      def object_store
        Provider.object_store
      end
    end # Resource
  end # Provisioning
end
