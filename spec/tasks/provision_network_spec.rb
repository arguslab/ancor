require 'spec_helper'

module Ancor
  module Tasks

    describe ProvisionNetwork do
      include OpenStackHelper

      let(:delete_task) { DeleteNetwork.new }

      it 'creates and deletes a network', live: true do
        network_id = setup_network_fixture

        subject.perform network_id
        #delete_task.perform network_id
      end
    end

  end
end
