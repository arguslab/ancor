module Ancor
  module Tasks
    class DeallocatePublicIp < BaseExecutor
      def perform(pip_id)
        public_ip = PublicIp.find pip_id
        locator = Provider::ServiceLocator.instance

        endpoint = public_ip.provider_endpoint

        connection = locator.connection(endpoint)
        service = locator.service(endpoint.type, Provider::PublicIpService)
        service.delete(connection, public_ip)

        public_ip.destroy

        true
      end
    end # DeallocatePublicIp
  end # Tasks
end
