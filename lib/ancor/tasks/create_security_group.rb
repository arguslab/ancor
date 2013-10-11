module Ancor
  class CreateSecurityGroupTask < BaseTask
    def perform(instance_id)
      puts "Creating security group for instance #{instance_id}"
      return true
    end
  end
end
