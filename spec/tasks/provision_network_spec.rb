require 'spec_helper'

module Ancor
  module Tasks
    describe ProvisionNetwork do
      include OsNetworkHelper

      it 'creates a network', live: true do
        network_id = setup_network_fixture
        subject.perform(network_id)
      end
    end
  end
end