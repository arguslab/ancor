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
module Ancor
  module Provider
    class BaseService
      include Loggable
      include Operational

      class << self
        # Registers this service class with the service locator for the given
        # provider type
        #
        # @example
        #   class AmazonInstanceService < InstanceService
        #     interacts_with :aws
        #   end
        #
        #   class OsNeutronNetworkService < NetworkService
        #     interacts_with :os_neutron
        #   end
        #
        # @param [Symbol] provider_type
        # @return [undefined]
        def interacts_with(provider_type)
          locator.register_service provider_type, self
        end

        private

        # @return [ServiceLocator]
        def locator
          ServiceLocator.instance
        end
      end
    end # BaseService
  end # Provider
end
