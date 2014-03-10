module Ancor
  module Tasks
    class CleanPuppetCertificate < BaseExecutor
      include Conductor::ClientUtil

      def perform(instance_id)
        instance = Instance.find instance_id

        ca_client = rpc_client :puppetca
        client_sync {
          # TODO How do we handle FQDN here?
          # TODO Check output; should be "cert does not exist" or "success"
          ca_client.clean certname: "#{instance.name}.openstacklocal"
        }

        true
      end
    end # CleanPuppetCertificate
  end # Tasks
end
