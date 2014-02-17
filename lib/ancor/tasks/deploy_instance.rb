module Ancor
  module Tasks
    class DeployInstance < BaseExecutor

      def perform(instance_id)
        instance = Instance.find instance_id

        unless context["provisioned"]
          unless task_started? :provision
            perform_task :provision, ProvisionInstance, instance_id
            return false
          end

          return false unless task_completed? :provision
          context["provisioned"] = true
        end

        unless context["pushed"]
          create_wait_handle(:run_completed, instance_id: instance.id)
          context["pushed"] = true
          return false
        end

        return true
      end

    end # DeployInstance
  end # Tasks
end
