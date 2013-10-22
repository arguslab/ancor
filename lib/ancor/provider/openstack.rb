require 'ancor/provider/openstack_instance_service'
require 'ancor/provider/openstack_network_service'
require 'ancor/provider/openstack_security_group_service'

module Ancor
  module Provider

    module OpenStack
      PROVIDER_OS = 'OpenStack'

      def self.create_compute_connection(options)
        Fog::Compute.new({
          provider: PROVIDER_OS
        }.merge(options.symbolize_keys))
      end

      def self.create_network_connection(options)
        Fog::Network.new({
          provider: PROVIDER_OS
        }.merge(options.symbolize_keys))
      end

      def self.setup
        locator = ServiceLocator.instance

        locator.register_connection_factory(:os_nova, &method(:create_compute_connection))
        locator.register_connection_factory(:os_neutron, &method(:create_network_connection))
      end
    end

    OpenStack.setup

  end
end
