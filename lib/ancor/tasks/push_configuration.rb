module Ancor
  module Tasks
    class PushConfiguration < BaseExecutor
      include Conductor::ClientUtil

      def perform(instance_id)
        instance = Instance.find instance_id

        unless context[:ran]
          puppet_client = rpc_client :puppet, timeout: 3
          puppet_client.identity_filter instance.name

          client_sync {
            puppet_client.runonce
          }

          context[:ran] = true

          create_wait_handle(:run_completed, instance_id: instance.id)

          return false
        end

        return true
      end
    end # PushConfiguration
  end # Tasks
end
