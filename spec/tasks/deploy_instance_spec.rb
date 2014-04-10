require 'spec_helper'

module Ancor
  module Tasks
    describe DeployInstance do

      before(:each) do
        subject.task = Task.create!
      end

      let(:instance) do
        Instance.create!(name: 'test')
      end

      it 'creates a task chain for deploying an instance' do

        subject.perform(instance.id)

      end

    end
  end
end
