require 'spec_helper'

module Ancor
  module Tasks

    describe InitializeInstance do
      include OpenStackHelper

      let(:create_instance_task) { ProvisionInstance.new }
      let(:delete_instance_task) { DeleteInstance.new }

      let(:create_network_task) { ProvisionNetwork.new }
      let(:delete_network_task) { DeleteNetwork.new }

      before do
        conf_path = Rails.root.join('spec', 'config', 'mcollective.conf')
        lib_path = Rails.root.join('lib')

        config = MCollective::Config.instance
        config.loadconfig conf_path
        config.libdir << lib_path
      end

      it 'bootstraps an instance', long: true do
        network_id = setup_network_fixture
        instance_id = setup_instance_fixture network_id

        inject_user_data instance_id

        create_network_task.perform network_id
        create_instance_task.perform instance_id

        begin
          wait_for_initialize instance_id
        ensure
          delete_instance_task.perform instance_id
          delete_network_task.perform network_id
        end
      end

      private

      def wait_for_initialize(instance_id)
        until subject.perform instance_id
          puts "Waiting 10 seconds for instance to come up"
          sleep 10
        end
      end

      def inject_user_data(instance_id)
        instance = Instance.find instance_id

        user_data = File.read(Rails.root.join('spec', 'config', 'ubuntu.sh'))
        instance.provider_details['user_data'] = user_data

        instance.save
      end
    end

  end
end
