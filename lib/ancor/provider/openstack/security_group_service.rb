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

        return if secgroup_id && delete_by_id(connection, secgroup_id)

        # Instance did not have security group set, or the security group did not
        # exist. Make sure there is no similarly named security group.
        secgroup = connection.security_groups.find do |sg|
          sg.name == instance.name
        end

        delete_by_id(connection, secgroup.id) if secgroup

        # TODO Should we unset the secgroup_id provider detail?
      end

      # @param [Fog::Compute::OpenStack] connection
      # @param [Instance] instance
      # @return [undefined]
      def update(connection, instance)
        secgroup_id = instance.provider_details['secgroup_id']
        rules = instance.provider_details['secgroup_rules']

        os_secgroup = connection.security_groups.find do |sg|
          sg.id == secgroup_id
        end

        # For testing update sec gr with existing rules
        #connection.create_security_group_rule secgroup_id, 'tcp', 1, 100, '0.0.0.0/24'
        #connection.create_security_group_rule secgroup_id, 'udp', 1, 1000, '0.0.0.0/24'
        #connection.create_security_group_rule secgroup_id, 'icmp', -1, -1, '0.0.0.0/0'
        #os_secgroup.reload

        if os_secgroup.rules.empty?
          unless rules.empty?
            rules.each do |rule|
              connection.create_security_group_rule secgroup_id, rule['protocol'],
                                                    rule['from_port'], rule['to_port'],
                                                    rule['source']
            end
          end

        else
          os_rules = os_secgroup.rules

          rules.each do |rule|
            rule_exists = true
            os_rules.each do |os_rule|
              rule_exists = true
              break if os_rule['ip_protocol'] == rule['protocol'] &&
                       os_rule['from_port'] == rule['from_port'] &&
                       os_rule['to_port'] == rule['to_port'] &&
                       os_rule['ip_range']['cidr'] == rule['source']
              rule_exists = false
            end

            unless rule_exists
              connection.create_security_group_rule secgroup_id, rule['protocol'],
                                                    rule['from_port'], rule['to_port'],
                                                    rule['source']
            end
          end

          os_secgroup.reload
          updated_os_rules = os_secgroup.rules

          updated_os_rules.each do |os_rule|
            keep_rule = true
            rules.each do |rule|
              keep_rule = true
              break if os_rule['ip_protocol'] == rule['protocol'] &&
                       os_rule['from_port'] == rule['from_port'] &&
                       os_rule['to_port'] == rule['to_port'] &&
                       os_rule['ip_range']['cidr'] == rule['source']
              keep_rule = false
            end

            unless keep_rule
              connection.delete_security_group_rule os_rule['id']
            end
          end
        end
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
