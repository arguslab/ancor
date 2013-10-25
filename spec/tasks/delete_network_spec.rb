require 'spec_helper'

module Ancor
  module Tasks
    describe DeleteNetwork do

      # Ensure instance exists in db and 
      # on the cloud infrastructure: ec428b08-3b36-11e3-bee0-ce3f5508acd9
      it 'deletes a network', live: true do
        network_name = 'network-b1e518d85969bfb1'
        network = Network.where(name: network_name).first
        subject.perform(network.id)
      end
    end
  end
end