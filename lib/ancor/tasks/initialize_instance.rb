module Ancor
  module Tasks
    class InitializeInstance < BaseExecutor
      include Conductor::ClientUtil

      def initialize
        @options = {
          puppet_ipaddress: '192.168.100.104',
          puppet_host: 'ancor-edge'
        }
      end

      def perform(instance_id)
        instance = Instance.find instance_id

        # TODO Lock the instance?

        util_client = rpc_client :rpcutil, timeout: 3
        util_client.identity_filter instance.name

        unless attempt_initialize instance, util_client
          # Come back to this task when the instance has registered
          create_wait_handle(:instance_registered, instance_id: instance.id)
          return false
        end

        return true
      end

      private

      def attempt_initialize(instance, util_client)
        inventory = client_sync {
          util_client.inventory.first
        }

        return false unless inventory

        certname = "dahcert"
        ipaddress = @options[:puppet_ipaddress]

        ca_client = rpc_client :puppetca
        ca_client.identity_filter @options[:puppet_host]

        provision_client = rpc_client :provision
        provision_client.identity_filter instance.name

        # Clean the certificate on the CA
        client_sync {
          ca_client.clean certname: certname
        }

        # Set the Puppet HOSTS entry on the target instance
        client_sync {
          provision_client.set_puppet_host ipaddress: ipaddress
        }

        # Run puppet and request certificate from the master
        client_sync {
          provision_client.bootstrap_puppet
        }

        # Sign the instance CSR on the CA
        result = client_sync {
          ca_client.sign certname: certname
        }.first

        unless result && result[:statuscode] == 0
          raise 'Puppet certificate could not be signed for instance'
        end

        true
      end
    end # InitializeInstance
  end # Tasks
end
