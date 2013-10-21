module Ancor
  module Provider
    class BaseService
      include Operational

      class << self
        # Registers this service class with the service locator for the given
        # provider type
        #
        # @example
        #   class AmazonInstanceService
        #     interacts_with :aws
        #   end
        #
        #   class OsNeutronNetworkService
        #     interacts_with :os_neutron
        #   end
        #
        # @param [Symbol] provider_type
        # @return [undefined]
        def interacts_with(provider_type)
          locator.register_service provider_type, self
        end

        private

        # @return [ServiceLocator]
        def locator
          ServiceLocator.instance
        end
      end

      private

      # @return [ServiceLocator]
      def locator
        ServiceLocator.instance
      end
    end # BaseService
  end # Provider
end
