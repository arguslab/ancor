module Ancor
  module Tasks
    class UpdateSecurityGroup < BaseExecutor
      def perform(instance_id)
        puts "Updating security group for instance #{instance_id}"
        return true
      end
    end # UpdateSecurityGroup
  end # Tasks
end
