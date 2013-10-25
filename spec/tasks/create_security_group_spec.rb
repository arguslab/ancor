require 'spec_helper'

module Ancor
  module Tasks
    describe CreateSecurityGroup do
      include OsInstanceHelper

      # Make sure no security group exists with ec428b08-3b36-11e3-bee0-ce3f5508acd9
      it 'creates a security group for an instance', live: true do
        instance_id = setup_instance_fixture

        subject.perform instance_id
        # TODO delete security group
      end

    end
  end
end
