require 'spec_helper'

module Ancor
  module Tasks
    describe DeleteInstance do

      # Ensure instance exists in db and 
      # on the cloud infrastructure: ec428b08-3b36-11e3-bee0-ce3f5508acd9
      it 'deletes an instance', live: true do
        instance_name = 'ec428b08-3b36-11e3-bee0-ce3f5508acd9'
        instance = Instance.find instance_name
        subject.perform(instance.id)
      end
    end
  end
end
