module Ancor
  module Provider
    module ServiceLocator
      extend self

      # service(:os_nova, SecurityGroupService)
      #
      # @param [Symbol] provider_type
      # @param [Class] service_type
      # @return [BaseService]
      def service(provider_type, service_type)

      end

      # connection(instance.provider_endpoint)
      #
      # @param [ProviderEndpoint] endpoint
      # @return [Object]
      def connection(endpoint)

      end
    end
  end
end
