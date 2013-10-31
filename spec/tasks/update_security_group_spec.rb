require 'spec_helper'

module Ancor
  module Tasks

    describe UpdateSecurityGroup do
      include OpenStackHelper

      let(:create_task) { CreateSecurityGroup.new }
      let(:delete_task) { DeleteSecurityGroup.new }

      it 'updates security group rules for an instance', live: true do
        instance_id = setup_instance_fixture

        create_task.perform instance_id
        subject.perform instance_id
        delete_task.perform instance_id
      end
    end

  end
end