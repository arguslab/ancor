require 'spec_helper'

module Ancor
  module Tasks
    describe ProvisionInstance do
      include OsInstanceHelper

      let(:secgroup_task) { CreateSecurityGroup.new }
      let(:delete_instance_task) { DeleteInstance.new }
      let(:delete_secgroup_task) { DeleteSecurityGroup.new }

      it 'creates and deletes an instance', live: true do
        instance_id = setup_instance_fixture

        secgroup_task.perform instance_id

        subject.perform instance_id

        delete_instance_task.perform instance_id
        
        delete_secgroup_task.perform instance_id

      end

    end
  end
end
