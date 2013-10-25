module Ancor
  module Provider
    class OpenStackSecurityGroupService < SecurityGroupService
      interacts_with :os_nova

      # @param [Fog::Compute::OpenStack] connection
      # @param [Instance] instance
      # @return [undefined]
      def create(connection, instance)
        secgroup_id = instance.provider_details['secgroup_id']

        if secgroup_id
          # Ensure that the security group actually exists
          begin
            connection.security_groups.get secgroup_id
            return
          rescue Fog::Compute::OpenStack::NotFound
            # Identifier is incorrect
          end
        end

        secgroup = connection.security_groups.find do |sg|
          sg.name == instance.name
        end

        if secgroup
          instance.provider_details['secgroup_id'] = secgroup.id
          instance.save

          return
        end

        options = {
          name: instance.name,
          description: 'Maintained by ANCOR'
        }

        secgroup = connection.security_groups.create options

        instance.provider_details['secgroup_id'] = secgroup.id
        instance.save
      end

      # @param [Fog::Compute::OpenStack] connection
      # @param [Instance] instance
      # @return [undefined]
      def delete(connection, instance)
        secgroup_id = instance.provider_details['secgroup_id']

        return if secgroup_id && delete_by_id(secgroup_id)

        # Instance did not have security group set, or the security group did not
        # exist. Make sure there is no similarly named security group.
        secgroup = connection.security_groups.find do |sg|
          sg.name == instance.name
        end

        delete_by_id(secgroup.id) if secgroup

        # TODO Should we unset the secgroup_id provider detail?
      end

      # @param [Fog::Compute::OpenStack] connection
      # @param [Instance] instance
      # @return [undefined]
      def update(connection, instance)
        secgroup_id = instance.provider_details['secgroup_id']

        connection.create_security_group_rule id, 1, 65535, 'tcp'
        connection.create_security_group_rule id, 1, 65535, 'udp'
        connection.create_security_group_rule id, -1, -1, 'icmp'
      end

      private

      def delete_by_id(connection, id)
        connection.delete_security_group id
        true
      rescue Fog::Compute::OpenStack::NotFound
        false
      end
    end # OpenStackSecurityGroupService
  end # Provider
end
