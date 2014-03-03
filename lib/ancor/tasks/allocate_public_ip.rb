module Ancor
  module Tasks
    class AllocatePublicIp < BaseExecutor
      def perform(pip_id)
        public_ip = PublicIp.find pip_id
        locator = Provider::ServiceLocator.instance

        endpoint = public_ip.provider_endpoint

        connection = locator.connection(endpoint)
        service = locator.service(endpoint.type, Provider::PublicIpService)
        service.create(connection, public_ip)

        true
      end
    end # AllocatePublicIp
  end # Tasks
end
