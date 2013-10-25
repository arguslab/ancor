require 'spec_helper'
require 'securerandom'

module Ancor
  module Tasks
    describe DeployInstance do
      it 'does stuff' do
        #Instance.delete_all
        instance_name = SecureRandom.uuid
        test_instance = Instance.create(
                          name: instance_name
                        )
        #instance_id = test_instance.id
        # puts "instance_id = " + instance_id
        #task = Task.create(type: "Ancor::Tasks::DeployInstance", arguments: [instance_id])

        # TaskWorker.perform_async(task.id.to_s)
      end
    end
  end
end
