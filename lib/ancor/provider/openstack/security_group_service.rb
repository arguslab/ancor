module Ancor
  module Provider
    class OpenStackSecurityGroupService < SecurityGroupService
      interacts_with :os_nova

      # @param [Fog::Compute::OpenStack] connection
      # @param [Instance] instance
      # @return [undefined]
      def create(connection, instance)
        if instance.provider_details["secgroup_id"]
          # TODO Check if security group is actually present
          return
        end

        secgroup = connection.security_groups.find do |sg|
          sg.name == instance.name
        end

        if secgroup
          instance.provider_details["secgroup_id"] = secgroup.id
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
        # TODO Implement this method
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
    end # OpenStackSecurityGroupService
  end # Provider
end
