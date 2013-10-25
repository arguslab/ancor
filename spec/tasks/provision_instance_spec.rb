require 'spec_helper'

module Ancor
  module Tasks
    describe ProvisionInstance do
      include OsInstanceHelper

      let(:secgroup_task) { CreateSecurityGroup.new }
      let(:delete_instance_task) { DeleteInstance.new }

      # No instance exists with ec428b08-3b36-11e3-bee0-ce3f5508acd9
      # No instance exists with IP 10.97.226.20
      # Ensure security group ec428b08-3b36-11e3-bee0-ce3f5508acd9 exists
      it 'provisions an instance', live: true do
        instance_id = setup_instance_fixture

        secgroup_task.perform instance_id

        subject.perform instance_id

        delete_instance_task.perform instance_id
        # TODO delete security group
      end

    end
  end
end
