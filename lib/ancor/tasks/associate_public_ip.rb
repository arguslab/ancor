module Ancor
  module Tasks
    class AssociatePublicIp < BaseExecutor
      def perform(pip_id, instance_id)
        public_ip = PublicIp.find pip_id
        instance = Instance.find instance_id

        locator = Provider::ServiceLocator.instance

        endpoint = public_ip.provider_endpoint

        connection = locator.connection(endpoint)
        service = locator.service(endpoint.type, Provider::PublicIpService)
        service.associate(connection, public_ip, instance)

        true
      end
    end # AssociatePublicIp
  end # Tasks
end
