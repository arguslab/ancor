module Ancor
  module Tasks
    class DeleteSecurityGroup < BaseExecutor
      def perform(secgroup_id)
        secgroup = SecurityGroup.find secgroup_id
        locator = Provider::ServiceLocator.instance

        endpoint = secgroup.provider_endpoint

        connection = locator.connection(endpoint)
        service = locator.service(endpoint.type, Provider::SecurityGroupService)
        service.delete(connection, secgroup)

        secgroup.destroy

        return true
      end
    end # DeleteSecurityGroup
  end # Tasks
end
