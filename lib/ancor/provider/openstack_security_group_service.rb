require 'fog'

module Ancor
  module Provider
    class OpenStackSecurityGroupService < SecurityGroupService

      def create_security_group(connection,instance)
        options = {
          name: instance.name,
          description: 'created by Ancor'
        }

        sec_group = connection.security_groups.create options

        instance.provider_details["secgroup_id"] = sec_group.id

      end

      def update_security_group(connection,instance)
        secgroup_id = instance.provider_details["secgroup_id"]
        connection.create_security_group_rule id, 1, 65535, 'tcp'
        connection.create_security_group_rule id, 1, 65535, 'udp'
        connection.create_security_group_rule id, -1, -1, 'icmp'
      end

    end # OpenStackSecurityGroupService
  end 
end