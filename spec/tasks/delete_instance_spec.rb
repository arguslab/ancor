require 'spec_helper'

module Ancor
  module Tasks
    describe DeleteInstance do
      include OsInstanceHelper

      let(:secgroup_task) { CreateSecurityGroup.new }
      let(:provision_task) { ProvisionInstance.new }

      it 'deletes an instance', live: true do
        instance_id = setup_instance_fixture

        secgroup_task.perform instance_id
        provision_task.perform instance_id

        subject.perform instance_id

        # TODO delete security group
      end

    end
  end
end
