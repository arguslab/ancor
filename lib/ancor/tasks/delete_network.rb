module Ancor
  module Tasks
    class DeleteNetwork < BaseExecutor
      def perform(network_id)
        network = Network.find network_id
        locator = Provider::ServiceLocator.instance

        endpoint = network.provider_endpoint

        connection = locator.connection(endpoint)
        service = locator.service(endpoint.type, Provider::NetworkService)
        service.delete(connection, network)

        network.destroy

        return true
      end
    end # DeleteNetwork
  end # Tasks
end
