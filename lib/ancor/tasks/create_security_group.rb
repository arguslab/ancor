module Ancor
  module Tasks
    class CreateSecurityGroup < BaseExecutor
      def perform(instance_id)
        puts "Creating security group for instance #{instance_id}"
        return true
      end
    end # CreateSecurityGroup
  end # Tasks
end
