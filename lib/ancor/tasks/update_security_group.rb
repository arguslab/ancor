module Ancor
  module Tasks
    class UpdateSecurityGroup < BaseExecutor
      def perform(instance_id)
        instance = Instance.find instance_id
        locator = Provider::ServiceLocator.instance

        endpoint = instance.provider_endpoint

        connection = locator.connection(endpoint)
        service = locator.service(endpoint.type, Provider::SecurityGroupService)
        service.update(connection, instance)

        return true
      end
    end # UpdateSecurityGroup
  end # Tasks
end
