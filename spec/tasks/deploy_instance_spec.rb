require 'spec_helper'
require 'securerandom'

module Ancor
  describe DeployInstanceTask do
    it 'does stuff' do
      instance_id = SecureRandom.uuid
      task = Task.create(type: "Ancor::DeployInstanceTask", arguments: [instance_id])

      TaskWorker.perform_async(task.id.to_s)
    end
  end
end
