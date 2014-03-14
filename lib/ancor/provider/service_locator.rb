# Author: Ian Unruh, Alexandru G. Bardas
# Copyright (C) 2013-2014 Argus Cybersecurity Lab, Kansas State University
#
# This file is part of ANCOR.
#
# ANCOR is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ANCOR is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with ANCOR.  If not, see <http://www.gnu.org/licenses/>.
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
