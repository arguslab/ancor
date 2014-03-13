module Ancor
  module Tasks
    class GeneratePuppetCertificate < BaseExecutor
      include Conductor::ClientUtil

      def perform(instance_id)
        instance = Instance.find instance_id

        ca_client = rpc_client :puppetca
        results = client_sync {
          ca_client.generate certname: "#{instance.name}.#{instance.environment.slug}"
        }

        data = results[0].results[:data]

        # TODO Check output

        instance.cmt_details = data.except(:out) # No need to store the output
        instance.save!

        true
      end
    end # GeneratePuppetCertificate
  end # Tasks
end
