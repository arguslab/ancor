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
          progress_bar: false
        }.merge options

        MCollective::RPC::Client.new(agent_name.to_s, options: options)
      end
    end # ClientUtil
  end # Conductor
end
