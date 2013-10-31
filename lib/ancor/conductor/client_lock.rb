module Ancor
  module Conductor
    # Global lock used to synchronize the use of the MCollective client
    module ClientLock
      extend self

      # @return [undefiend]
      def setup
        @mutex = Mutex.new
      end

      # @yield
      # @return [Object] Result of the yield
      def synchronize
        @mutex.synchronize { yield }
      end

      setup
    end # ClientLock
  end # Conductor
end
