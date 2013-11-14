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
          puts "Provision finished"
          context["provisioned"] = true
        end

        unless context["initialized"]
          unless task_started? :initialize
            perform_task :initialize, InitializeInstance, instance_id
            return false
          end

          return false unless task_completed? :initialize
          puts "Initialize finished"
          context["initialized"] = true
        end

        unless context["pushed"]
          unless task_started? :push
            perform_task :push, PushConfiguration, instance_id
            return false
          end

          return false unless task_completed? :push
          puts "Completely done"
          context["pushed"] = true
        end

        return true
      end

    end # DeployInstance
  end # Tasks
end
