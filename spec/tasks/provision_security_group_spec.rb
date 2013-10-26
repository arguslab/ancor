require 'spec_helper'

module Ancor
  module Tasks
    describe CreateSecurityGroup do
      include OsInstanceHelper

      let(:secgroup_delete_task) { DeleteSecurityGroup.new }
    
      it 'creates and deletes a security group for an instance', live: true do
        instance_id = setup_instance_fixture

        subject.perform instance_id

        secgroup_delete_task.perform instance_id
      end

    end
  end
end
