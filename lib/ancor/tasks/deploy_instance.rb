module Ancor
  module Tasks
    class DeployInstance < BaseExecutor
      def perform(instance_id)
        unless task_completed? :create_secgroup
          perform_task :create_secgroup, CreateSecurityGroup, instance_id
          return false
        end
      end
    end # DeployInstance
  end # Tasks
end
