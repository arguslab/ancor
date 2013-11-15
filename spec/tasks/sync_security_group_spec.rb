require 'spec_helper'

module Ancor
  module Tasks

    describe SyncSecurityGroup do
      include OpenStackHelper

      let(:delete_task) { DeleteSecurityGroup.new }

      it 'sets up initial security group rules', live: true do
        secgroup_id = setup_secgroup_fixture

        begin
          subject.perform secgroup_id
          os_rules_for(secgroup_id).size.should == 3
        ensure
          delete_task.perform secgroup_id
        end
      end

      it 'keeps security group rules in sync', live: true do
        secgroup_id = setup_secgroup_fixture

        begin
          subject.perform secgroup_id
          change_secgroup_rules secgroup_id
          subject.perform secgroup_id

          # Started with 3 rules (+3)
          # Added 2 rules (+2)
          # Removed 1 rule (-1)
          os_rules_for(secgroup_id).size.should == 4
        ensure
          delete_task.perform secgroup_id
        end
      end

      private

      # @param [String] id
      # @return [Array] Contains hashes of rules in OpenStack format
      def os_rules_for(id)
        secgroup = SecurityGroup.find id
        secgroup_id = secgroup.provider_details['secgroup_id']

        locator = Provider::ServiceLocator.instance
        connection = locator.connection secgroup.provider_endpoint

        connection.security_groups.get(secgroup_id).rules
      end

      # @param [String] id
      # @return [undefined]
      def change_secgroup_rules(id)
        secgroup = SecurityGroup.find id

        cidr = '0.0.0.0/0'

        rules = secgroup.rules

        rules << SecurityGroupRule.new(protocol: :tcp, from: 80, to: 80, cidr: cidr)
        rules << SecurityGroupRule.new(protocol: :tcp, from: 443, to: 443, cidr: cidr)

        rules.each { |rule|
          rule.delete if rule.protocol == :icmp
        }

        secgroup.save
      end
    end

  end
end
