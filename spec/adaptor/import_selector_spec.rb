require 'spec_helper'

module Ancor
  module Adaptor

    describe ImportSelector do
      subject { ImportSelector.instance }

      it 'resolves instances for roles' do
        role_web = create_role(:web)
        role_db = create_role(:db)
        role_redis = create_role(:redis)

        channel_querying = SinglePortChannel.create(slug: :querying, exporter: role_db, importers: [role_web], protocol: :tcp)
        channel_redis = SinglePortChannel.create(slug: :redis, exporter: role_redis, importers: [role_web], protocol: :tcp)

        network = Network.create

        instance_web = create_instance(role_web, network, '1.1.1.1')

        instance_db = create_instance(role_db, network, '2.2.2.2') { |i|
          select_channel i, channel_querying
        }

        instance_redis = create_instance(role_redis, network, '3.3.3.3') { |i|
          select_channel i, channel_redis
        }

        pp subject.select(instance_web)

        binding.pry
      end

      private

      def select_channel(instance, channel)
        instance.channel_selections << SinglePortChannelSelection.new(channel: channel, port: rand(10_000..50_000))
      end

      def create_instance(role, network, ip)
        scenario = role.scenarios.first
        instance = Instance.new(role: role, scenario: scenario, name: "#{role.slug}0")
        InstanceInterface.create(instance: instance, network: network, ip_address: ip)
        yield instance if block_given?
        instance.save
        instance
      end

      def create_role(slug)
        scenario = Scenario.create(slug: :default)
        Role.create(slug: slug, scenarios: [scenario])
      end
    end

  end
end
