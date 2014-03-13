module Ancor
  module Tasks
    class DeployInstance < BaseExecutor
      def perform(instance_id)
        instance = Instance.find instance_id

        ensure_task_chain [
          [:generate_cert, GeneratePuppetCertificate, instance_id],
          [:generate_bootstrap, GenerateInstanceBootstrap, instance_id],
          [:provision, ProvisionInstance, instance_id],
          [:push, PushConfiguration, instance_id],
        ]
      end
    end # DeployInstance
  end # Tasks
end
