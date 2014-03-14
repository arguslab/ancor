# Author: Ian Unruh, Alexandru G. Bardas
# Copyright (C) 2013-2014 Argus Cybersecurity Lab, Kansas State University
#
# This file is part of ANCOR.
#
# ANCOR is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ANCOR is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with ANCOR.  If not, see <http://www.gnu.org/licenses/>.
require 'spec_helper'

module Ancor
  module Tasks

    describe ProvisionInstance do
      include OpenStackHelper

      let(:create_network_task) { ProvisionNetwork.new }
      let(:delete_network_task) { DeleteNetwork.new }

      let(:sync_secgroup_task) { SyncSecurityGroup.new }
      let(:delete_secgroup_task) { DeleteSecurityGroup.new }

      let(:delete_instance_task) { DeleteInstance.new }

      it 'creates and deletes an instance', live: true do
        network_id = setup_network_fixture
        secgroup_id = setup_secgroup_fixture
        instance_id = setup_instance_fixture network_id, secgroup_id

        begin
          create_network_task.perform network_id
          sync_secgroup_task.perform secgroup_id

          subject.perform instance_id
        ensure
          delete_instance_task.perform instance_id
          delete_secgroup_task.perform secgroup_id
          delete_network_task.perform network_id
        end
      end
    end

  end
end
