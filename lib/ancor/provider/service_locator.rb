module Ancor
  module Provider
    # This class MUST be thread-safe
    class ServiceLocator
      include Singleton

      def initialize
        @services = ConcurrentList.new
        @connections = ThreadSafe::Cache.new
        @connection_factories = ThreadSafe::Cache.new
      end

      def register_connection(endpoint_id, connection)
        @connections.put(endpoint_id, connection)
      end

      def register_connection_factory(provider_type, &factory)
        @connection_factories.put(provider_type, factory)
      end

      def register_service(provider_type, service_class)
        @services.push(ServiceRegistration.new(provider_type, service_class))
      end

      # @example
      #   locator.service :os_nova, SecurityGroupService
      #
      # @raise [ServiceNotFoundError]
      #
      # @param [Symbol] provider_type
      # @param [Class] service_class
      # @return [BaseService]
      def service(provider_type, service_class)
        @services.each do |service|
          if service.matches? provider_type, service_class
            return service.instance
          end
        end

        raise ServiceNotFoundError, "Service #{service_class} not found for provider #{provider_type}"
      end

      # @example
      #   locator.connection instance.provider_endpoint
      #
      # @param [ProviderEndpoint] endpoint
      # @return [Object]
      def connection(endpoint)
        endpoint_id = endpoint.id.to_s

        @connections.compute_if_absent(endpoint_id) do
          @connection_factories.get(endpoint.type).call(endpoint.options)
        end
      end
    end # ServiceLocator

    # This class is thread-safe
    class ServiceRegistration
      def initialize(provider_type, service_class)
        @provider_type = provider_type
        @service_class = service_class
        @mutex = Mutex.new
      end

      def matches?(provider_type, service_class)
        @provider_type == provider_type && @service_class <= service_class
      end

      def instance
        unless @instance
          @mutex.synchronize do
            @instance ||= @service_class.new
          end
        end

        @instance
      end
    end # ServiceRegistration

    class ServiceNotFoundError < RuntimeError; end
  end
end
