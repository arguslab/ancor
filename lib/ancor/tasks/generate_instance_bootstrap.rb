module Ancor
  module Tasks
    class GenerateInstanceBootstrap < BaseExecutor
      def perform(instance_id)
        instance = Instance.find instance_id
        certname = "#{instance.name}.#{instance.environment.slug}"

        config = Ancor.config

        template = ERB.new(
          File.read(File.expand_path('spec/config/ubuntu-precise.sh.erb', Rails.root))
        )
        mco_template = ERB.new(
          File.read(File.expand_path('spec/config/mcollective/server.cfg.erb', Rails.root))
        )

        mcollective_server_config = mco_template.result(binding)

        instance.provider_details[:userdata] = template.result(binding)
        instance.save!

        return true
      end
    end # GenerateInstanceBootstrap
  end # Tasks
end
