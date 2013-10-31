require 'spec_helper'

module Ancor
  module Tasks

    describe CreateSecurityGroup do
      include OpenStackHelper

      let(:delete_task) { DeleteSecurityGroup.new }

      it 'creates and deletes a security group', live: true do
        secgroup_id = setup_secgroup_fixture

        subject.perform secgroup_id
        delete_task.perform secgroup_id
      end
    end

  end
end
