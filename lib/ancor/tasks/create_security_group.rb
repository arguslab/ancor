module Ancor
  module Tasks
    class CreateSecurityGroup < BaseExecutor
      def perform(instance_id)
        instance = Instance.find instance_id
        locator = Provider::ServiceLocator.instance

        endpoint = instance.provider_endpoint

        connection = locator.connection(endpoint)
        service = locator.service(endpoint.type, Provider::SecurityGroupService)
        service.create(connection, instance)

        return true
      end
    end # CreateSecurityGroup
  end # Tasks
end
