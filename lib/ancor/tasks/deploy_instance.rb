module Ancor
  module Tasks
    class DeployInstance < BaseExecutor

      def perform(instance_id)
        unless context["secgroup_created"]
          unless task_started? :create_secgroup
            perform_task :create_secgroup, CreateSecurityGroup, instance_id
            return false
          end

          return false unless task_completed? :create_secgroup
          puts "Create security group finished"
          context["secgroup_created"] = true
        end


        unless task_started? :update_secgroup
          perform_task :update_secgroup, UpdateSecurityGroup, instance_id
        end

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


        unless context["secgroup_updated"]
          return false unless task_completed? :update_secgroup
          puts "Update security group finished"
          context["secgroup_updated"] = true
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
