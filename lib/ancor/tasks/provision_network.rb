module Ancor
  module Tasks
    class ProvisionNetwork < BaseExecutor
      def perform(network_id)
        network = Network.find network_id
        locator = Provider::ServiceLocator.instance

        endpoint = network.provider_endpoint

        connection = locator.connection(endpoint)
        service = locator.service(endpoint.type, Provider::NetworkService)
        service.create(connection, network)

        return true
      end
    end # ProvisionNetwork
  end # Tasks
end
