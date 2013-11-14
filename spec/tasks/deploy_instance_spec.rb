require 'spec_helper'
require 'securerandom'

module Ancor
  module Tasks
    describe DeployInstance do
      include OpenStackHelper
      include InitializeHelper
      include Operational

      let(:create_secgr_task) { CreateUpdateSecurityGroup.new }
      let(:delete_secgr_task) { DeleteSecurityGroup.new }

      let(:create_instance_task) { ProvisionInstance.new }
      let(:delete_instance_task) { DeleteInstance.new }

      let(:create_network_task) { ProvisionNetwork.new }
      let(:delete_network_task) { DeleteNetwork.new }

      it 'deploys an instance', long: true do
        network_id = setup_network_fixture
        secgroup_id = setup_secgroup_fixture
        instance_id = setup_instance_fixture network_id, secgroup_id
        inject_user_data instance_id

        create_network_task.perform network_id
        create_secgr_task.perform secgroup_id

        deploy_task = Task.create(type: DeployInstance.name, arguments: [instance_id])

        TaskWorker.perform_async(deploy_task.id.to_s)

        begin
          wait_until(600) do
            deploy_task.reload
            deploy_task.completed?
          end

        ensure
          delete_instance_task.perform instance_id
          delete_secgr_task.perform secgroup_id
          delete_network_task.perform network_id
        end
      end
    end
  end
end