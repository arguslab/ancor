require 'spec_helper'

module Ancor
  module Tasks

    describe 'webhook integration' do
      include OpenStackHelper
      include InitializeHelper
      include Operational

      let(:create_instance_task) { ProvisionInstance.new }
      let(:delete_instance_task) { DeleteInstance.new }

      let(:create_network_task) { ProvisionNetwork.new }
      let(:delete_network_task) { DeleteNetwork.new }

      it 'integrates Rails, Sidekiq, MCollective, Puppet', long: true do
        network_id = setup_network_fixture
        instance_id = setup_instance_fixture network_id

        inject_user_data instance_id

        create_network_task.perform network_id
        create_instance_task.perform instance_id

        task_initialize = Task.create(type: InitializeInstance.name, arguments: [instance_id])
        task_push = Task.create(type: PushConfiguration.name, arguments: [instance_id])

        task_initialize.create_wait_handle(task_push)

        TaskWorker.perform_async(task_initialize.id.to_s)

        begin
          wait_until(600) do
            task_push.reload
            task_push.completed?
          end
        ensure
          delete_instance_task.perform instance_id
          delete_network_task.perform network_id
        end
      end
    end

  end
end
