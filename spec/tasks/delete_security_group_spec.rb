require 'spec_helper'

module Ancor
  module Tasks
    describe DeleteSecurityGroup do
      include OsInstanceHelper

      let(:secgroup_task) { CreateSecurityGroup.new }

      # Make sure no security group exists with ec428b08-3b36-11e3-bee0-ce3f5508acd9
      it 'deletes a security group for an instance', live: true do
        instance_id = setup_instance_fixture
        secgroup_task.perform instance_id

        subject.perform instance_id
      end

    end
  end
end
