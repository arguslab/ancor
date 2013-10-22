module Ancor
  module Tasks
    class ProvisionInstance < BaseExecutor
      def perform(instance_id)
        instance = Instance.find instance_id
        locator = Provider::ServiceLocator.instance

        endpoint = instance.provider_endpoint

        connection = locator.connection(endpoint)
        service = locator.service(endpoint.type, Provider::InstanceService)
        service.create(connection, instance)

        wait_until do
          if service.error?(connection, instance)
            raise 'Error creating instance'
          end

          service.active?(connection, instance)
        end

        return true
      end
    end # ProvisionInstance
  end # Tasks
end
