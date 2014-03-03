module Ancor
  module Tasks
    class DisassociatePublicIp < BaseExecutor
      def perform(pip_id)
        public_ip = PublicIp.find pip_id
        locator = Provider::ServiceLocator.instance

        endpoint = public_ip.provider_endpoint

        connection = locator.connection(endpoint)
        service = locator.service(endpoint.type, Provider::PublicIpService)
        service.disassociate(connection, public_ip)

        true
      end
    end # DisassociatePublicIp
  end # Tasks
end
