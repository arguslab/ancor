module Ancor
  module Tasks
    class DeleteInstance < BaseExecutor
      def perform(instance_id)
        instance = Instance.find instance_id
        locator = Provider::ServiceLocator.instance

        endpoint = instance.provider_endpoint

        connection = locator.connection(endpoint)
        service = locator.service(endpoint.type, Provider::InstanceService)
        service.delete(connection, instance)

        return true
      end
    end # DeleteInstance
  end # Tasks
end