module Ancor
  module Provider
    class OpenStackSecurityGroupService < SecurityGroupService
      interacts_with :os_nova

      # @param [Fog::Compute::OpenStack] connection
      # @param [SecurityGroup] secgroup
      # @return [undefined]
      def create(connection, secgroup)
        secgroup_id = secgroup.provider_details[:secgroup_id]

        if secgroup_id
          # Ensure that the security group actually exists
          begin
            connection.security_groups.get secgroup_id
            return
          rescue Fog::Compute::OpenStack::NotFound
            # Identifier is incorrect
          end
        end

        os_secgroup = connection.security_groups.find do |sg|
          sg.name == secgroup.name
        end

        unless os_secgroup
          options = {
            name: secgroup.name,
            description: 'Maintained by ANCOR'
          }

          os_secgroup = connection.security_groups.create options
        end

        secgroup.provider_details[:secgroup_id] = os_secgroup.id
        secgroup.save
      end

      # @param [Fog::Compute::OpenStack] connection
      # @param [SecurityGroup] secgroup
      # @return [undefined]
      def delete(connection, secgroup)
        secgroup_id = secgroup.provider_details[:secgroup_id]

        return if secgroup_id && delete_by_id(connection, secgroup_id)

        secgroup = connection.security_groups.find do |sg|
          sg.name == secgroup.name
        end

        delete_by_id(connection, secgroup.id) if secgroup

        # TODO Should we unset the secgroup_id provider detail?
      end

      # @param [Fog::Compute::OpenStack] connection
      # @param [SecurityGroup] secgroup
      # @return [undefined]
      def update(connection, secgroup)
        secgroup_id = secgroup.provider_details[:secgroup_id]
        os_secgroup = connection.security_groups.get secgroup_id

        os_rules = os_secgroup.rules.map &:deep_symbolize_keys
        rules = secgroup.securty_group_rules

        rules_to_add = rules.reject { |rule|
          # The rule that we want already exists in the OS ruleset
          os_rules.any? { |os_rule|
            rule_equal? rule, os_rule
          }
        }

        add_rules connection, secgroup_id, rules_to_add

        rules_to_delete = os_rules.reject { |os_rule|
          # The rule in the OS ruleset does not exist in the rules we want
          rules.any? { |rule|
            rule_equal? rule, os_rule
          }
        }

        delete_rules connection, rules_to_delete
      end

      private

      # @param [SecurityGroupRule] rule
      # @param [Hash] os_rule
      # @param [Boolean]
      def rule_equal?(rule, os_rule)
        rule.from == os_rule[:from_port] &&
          rule.to == os_rule[:to_port] &&
          rule.protocol == os_rule[:ip_protocol].to_sym &&
          rule.cidr == os_rule[:ip_range][:cidr]
      end

      # @param [Fog::Compute::OpenStack] connection
      # @param [String] secgroup_id
      # @param [Array] rules
      # @return [undefined]
      def add_rules(connection, secgroup_id, rules)
        rules.each do |rule|
          connection.create_security_group_rule secgroup_id, rule.protocol, rule.from, rule.to, rule.cidr
        end
      end

      # @param [Fog::Compute::OpenStack] connection
      # @param [Array] os_rules
      # @return [undefined]
      def delete_rules(connection, os_rules)
        os_rules.each do |os_rule|
          connection.delete_security_group_rule os_rule[:id]
        end
      end

      # @param [Fog::Compute::OpenStack] connection
      # @param [String] id
      # @return [Boolean] Returns true if security group was deleted
      def delete_by_id(connection, id)
        connection.delete_security_group id
        true
      rescue Fog::Compute::OpenStack::NotFound
        false
      end
    end # OpenStackSecurityGroupService
  end # Provider
end
