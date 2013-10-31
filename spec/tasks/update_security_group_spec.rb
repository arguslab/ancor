require 'spec_helper'

module Ancor
  module Tasks

    describe UpdateSecurityGroup do
      include OpenStackHelper

      let(:create_task) { CreateSecurityGroup.new }
      let(:delete_task) { DeleteSecurityGroup.new }

      it 'sets up initial security group rules', live: true do
        secgroup_id = setup_secgroup_fixture

        create_task.perform secgroup_id
        subject.perform secgroup_id
        delete_task.perform secgroup_id
      end

      it 'keeps security group rules in sync', live: true do
        secgroup_id = setup_secgroup_fixture

        create_task.perform secgroup_id

        subject.perform secgroup_id
        change_secgroup_rules secgroup_id
        subject.perform secgroup_id

        # TODO Ensure that the rules are actually in sync

        delete_task.perform secgroup_id
      end

      private

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
