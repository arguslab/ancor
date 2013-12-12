module Ancor
  module Adaptor
    class AdaptationEngine
      include Loggable

      attr_accessor :network_builder, :instance_builder

      def initialize
        @network_builder = proc {}
        @instance_builder = proc {}

        @next_ip = 10
      end

      def plan
        network = build_network
        instances = []

        Role.all.each do |role|
          puts "Building #{role.min} instances for role #{role.slug}"
          role.min.times do |index|
            instances.push(build_instance(index, network, role))
          end
        end
      end

      def launch
        network = Network.first

        instances = Instance.all
        puts "Deploying #{instances.count} instances"

        network_task = Task.create(type: Tasks::ProvisionNetwork.name, arguments: [network.id])

        instances.each do |instance|
          instance_task = Task.create(type: Tasks::DeployInstance.name, arguments: [instance.id])
          network_task.create_wait_handle(instance_task)
        end

        TaskWorker.perform_async(network_task.id.to_s)
      end

      private

      def build_network
        network = Network.new
        network.cidr = "10.#{rand(0..254)}.#{rand(0..254)}.0/24"

        @network_builder.call(network)

        network.save!

        network
      end

      def build_instance(index, network, role)
        ip_address = network.cidr.split("0/24")[0] + @next_ip.to_s
        @next_ip += 1

        instance = Instance.new
        # DNS names can't have underscores T_T
        instance.name = "#{role.slug}#{index}".gsub "_", "-"
        instance.role = role
        instance.scenario = role.scenarios.first
        instance.planned_stage = :deploy

        select_channels(instance, role.exports).each { |cs| instance.channel_selections << cs }

        @instance_builder.call(instance)

        instance.save!

        interface = InstanceInterface.create!(network: network, instance: instance, ip_address: ip_address)

        instance
      end

      def select_channels(instance, channels)
        channels.map { |channel|
          case channel
          when SinglePortChannel
            SinglePortChannelSelection.new(channel: channel, port: rand(10_000..50_000))
          when PortRangeChannel
            from_port = rand(10_000..50_000)
            to_port = from_port + channel.size
            PortRangeChannelSelection.new(channel: channel, from_port: from_port, to_port: to_port)
          else
            raise ArgumentError
          end
        }
      end
    end # AdaptationEngine
  end # Adaptor
end
