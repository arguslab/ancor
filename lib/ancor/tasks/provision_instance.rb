module Ancor
  module Tasks
    class ProvisionInstance < BaseExecutor
      def perform(instance_id)
        #instance = Instance.find instance_id
        #provider = ProviderRegistry.get_provider_for(instance.provider)
        #provider.instances.provision(instance)

        puts "Provisioning instance #{instance_id}"
        return true
      end
    end # ProvisionInstance
  end # Tasks
end
