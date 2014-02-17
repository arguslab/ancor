module Ancor
  module Tasks
    class PushConfiguration < BaseExecutor
      include Conductor::ClientUtil

      def perform(instance_id)
        instance = Instance.find instance_id

        unless context[:ran]
          puppet_client = rpc_client :puppet
          puppet_client.identity_filter instance.name

          puts "Pushing configuration to #{instance.name}"

          client_sync {
            puppet_client.runonce(force: true)
          }

          context[:ran] = true

          create_wait_handle(:run_completed, instance_id: instance.id)

          return false
        end

        puts "Puppet run finished for #{instance.name}"

        return true
      end
    end # PushConfiguration
  end # Tasks
end
