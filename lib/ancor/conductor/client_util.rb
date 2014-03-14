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
  module Conductor
    module ClientUtil
      # Synchronizes the use of the MCollective client
      #
      # @yield
      # @return [Object] Result of the yield
      def client_sync
        ClientLock.synchronize { yield }
      end

      # Creates an MCollective RPC client for the given agent
      #
      # @param [Symbol] agent_name
      # @param [Hash] options
      # @return [MCollective::RPC::Client]
      def rpc_client(agent_name, options = {})
        options = {
          # progress_bar: false,
        }.merge(options)

        MCollective::RPC::Client.new(agent_name.to_s, options: options)
      end
    end # ClientUtil
  end # Conductor
end
