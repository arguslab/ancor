module Ancor
  module Tasks
    class PushConfiguration < BaseExecutor
      def perform(instance_id)
        puts "Pushing configuration to instance #{instance_id}"
        return true
      end
    end # PushConfiguration
  end # Tasks
end
