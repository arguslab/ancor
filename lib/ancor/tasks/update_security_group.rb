module Ancor
  module Tasks
    class UpdateSecurityGroup < BaseExecutor
      def perform(secgroup_id)
        secgroup = SecurityGroup.find secgroup_id
        locator = Provider::ServiceLocator.instance

        endpoint = secgroup.provider_endpoint

        connection = locator.connection(endpoint)
        service = locator.service(endpoint.type, Provider::SecurityGroupService)
        service.update(connection, secgroup)

        return true
      end
    end # UpdateSecurityGroup
  end # Tasks
end
