module Ancor
  module Provider
    class OpenStackInstanceService < InstanceService
      interacts_with :os_nova

      STATE_ACTIVE = 'ACTIVE'
      STATE_ERROR = 'ERROR'

      # @param [Fog::Compute::OpenStack] connection
      # @param [Instance] instance
      # @return [undefined]
      def create(connection, instance)
        # TODO Lock the instance for this operation

        os_instance = find_instance connection, instance
        if os_instance
          return if os_instance.state == STATE_ACTIVE
          if os_instance.state == STATE_ERROR
            raise 'Instance exists, but is in an error state'
          end
        end

        nics = build_nic_specifications instance
        secgroups = build_secgroups instance

        options = {
          name: instance.name,
          flavor_ref: instance.provider_details[:flavor_id],
          image_ref: instance.provider_details[:image_id],
          nics: nics,
          security_groups: secgroups,
          user_data: instance.provider_details[:user_data]
        }
        os_instance = connection.servers.create options

        # TODO This should be customizable
        wait_until(240) do
          os_instance.reload

          if os_instance.state == STATE_ERROR
            raise 'Error creating instance'
          end

          os_instance.state == STATE_ACTIVE
        end

        instance.provider_details[:instance_id] = os_instance.id
        instance.save
      end

      # @param [Fog::Compute::OpenStack] connection
      # @param [Instance] instance
      # @return [undefined]
      def delete(connection, instance)
        os_instance = find_instance connection, instance

        if os_instance
          os_instance.destroy
          # TODO This should be customizable
          wait_while(240) do
            os_instance.reload
          end
        end
      end

      private

      # Creates an array of security group identifiers that will be assigned to the instance
      #
      # @param [Instance] instance
      # @return [Array]
      def build_secgroups(instance)
        instance.security_groups.map { |secgroup|
          secgroup.provider_details[:secgroup_id]
        }.compact
      end

      # Creates an array of specifications used to attach an instance to its associated networks
      #
      # @param [Instance] instance
      # @return [Array]
      def build_nic_specifications(instance)
        instance.interfaces.map do |interface|
          network = interface.network
          ip_address = interface.ip_address

          specification = {
            net_id: network.provider_details[:network_id],
            # this is not limited to IPv4 addresses, Fog is just weird
            v4_fixed_ip: ip_address
          }

          specification.stringify_keys
        end
      end

      # @param [Fog::Compute::OpenStack] connection
      # @param [Instance] instance
      # @return [Fog::Compute::OpenStack::Server]
      def find_instance(connection, instance)
        instance_id = instance.provider_details[:instance_id]

        os_instance = connection.servers.get instance_id
        unless os_instance
          os_instance = connection.servers.find { |i|
            i.name == instance.name
          }
        end

        os_instance
      end
    end # OpenStackInstanceService
  end # Provider
end
