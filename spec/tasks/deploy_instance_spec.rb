require 'spec_helper'
require 'securerandom'

module Ancor
  module Tasks
    describe DeployInstance do
      it 'does stuff' do
        instance_id = SecureRandom.uuid
        task = Task.create(type: "Ancor::Tasks::DeployInstance", arguments: [instance_id])

        TaskWorker.perform_async(task.id.to_s)
      end
    end
  end
end
