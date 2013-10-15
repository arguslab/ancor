module Ancor
  module Tasks
    class InitializeInstance < BaseExecutor
      def perform(instance_id)
        puts "Initializing instance #{instance_id}"
        return true
      end
    end # InitializeInstance
  end # Tasks
end
