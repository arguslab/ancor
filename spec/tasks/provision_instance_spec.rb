require 'spec_helper'

module Ancor
  module Tasks

    describe ProvisionInstance do
      include OpenStackHelper

      let(:create_network_task) { ProvisionNetwork.new }
      let(:delete_network_task) { DeleteNetwork.new }
      let(:create_secgroup_task) { CreateSecurityGroup.new }
      let(:delete_instance_task) { DeleteInstance.new }
      let(:delete_secgroup_task) { DeleteSecurityGroup.new }

      it 'creates and deletes an instance', live: true do
        network_id = setup_network_fixture
        secgroup_id = setup_secgroup_fixture
        instance_id = setup_instance_fixture network_id, secgroup_id

        create_network_task.perform network_id
        create_secgroup_task.perform secgroup_id

        subject.perform instance_id

        delete_instance_task.perform instance_id
        delete_secgroup_task.perform secgroup_id
        delete_network_task.perform network_id
      end
    end

  end
end
