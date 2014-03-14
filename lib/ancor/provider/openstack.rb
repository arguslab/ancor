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
require 'ancor/provider/openstack/instance_service'
require 'ancor/provider/openstack/network_service'
require 'ancor/provider/openstack/public_ip_service'
require 'ancor/provider/openstack/security_group_service'

module Ancor
  module Provider

    module OpenStack
      PROVIDER_OS = 'OpenStack'

      def self.create_compute_connection(options)
        Fog::Compute.new({
          provider: PROVIDER_OS
        }.merge(options.symbolize_keys))
      end

      def self.create_network_connection(options)
        Fog::Network.new({
          provider: PROVIDER_OS
        }.merge(options.symbolize_keys))
      end

      def self.setup
        locator = ServiceLocator.instance

        locator.register_connection_factory(:os_nova, &method(:create_compute_connection))
        locator.register_connection_factory(:os_neutron, &method(:create_network_connection))
      end
    end

    OpenStack.setup

  end
end
