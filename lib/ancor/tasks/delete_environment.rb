module Ancor
  module Tasks
    class DeleteEnvironment < BaseExecutor
      def perform(environment_id)
        Environment.find(environment_id).destroy
      end
    end # DeleteEnvironment
  end # Tasks
end
