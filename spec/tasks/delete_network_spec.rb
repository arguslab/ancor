require 'spec_helper'

module Ancor
  module Tasks
    describe DeleteNetwork do
      include OsNetworkHelper

      let(:network_task) { ProvisionNetwork.new }
      
      it 'deletes a network', live: true do
        network_id = setup_network_fixture
        network_task.perform network_id

        subject.perform(network_id)
      end
    end
  end
end