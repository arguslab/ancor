module Ancor
  module Tasks
    class UnlockEnvironment < BaseExecutor
      def perform(environment_id)
        Environment.find(environment_id).unlock
      end
    end # UnlockEnvironment
  end # Tasks
end
