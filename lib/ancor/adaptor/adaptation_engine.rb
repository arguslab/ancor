module Ancor
  module Adaptor
    class AdaptationEngine
      include Loggable

      # Function that populates details for new network model objects
      # @return [Proc]
      attr_accessor :network_builder

      # Function that populates details for new instance model objects
      # @return [Proc]
      attr_accessor :instance_builder

      def initialize
        @network_builder = proc {}
        @instance_builder = proc {}

        @next_addresses = {}
      end

      # Queries the requirement model and creates a suitable system model
      # @return [undefined]
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

      # Starts the deployment of planned networks and instances
      #
      # This method call is asynchronous
      #
      # @return [undefined]
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

      # Creates a new network model object
      # @return [Network]
      def build_network
        network = Network.new
        network.cidr = "10.#{rand(0..254)}.#{rand(0..254)}.0/24"

        @network_builder.call(network)

        network.save!
        network
      end

      # Creates a new instance model object
      #
      # @param [Integer] index
      # @param [Network] network
      # @param [Role] role
      # @return [Instance]
      def build_instance(index, network, role)
        instance = Instance.new

        # Instance host names are not allowed to have underscores
        instance.name = "#{role.slug}#{index}".dasherize
        instance.role = role
        instance.scenario = role.scenarios.first

        attach_interface(instance, network)
        select_channels(instance, role.exports)

        @instance_builder.call(instance)

        instance.save!
        instance
      end

      # Attaches the given instance to the given network
      #
      # @param [Instance] instance
      # @param [Network] network
      # @return [InstanceInterface]
      def attach_interface(instance, network)
        last_octet = @next_addresses.fetch(network, 10)
        @next_addresses.store(network, last_octet + 1)

        ip_address = network.cidr.split('0/24')[0] + last_octet.to_s

        InstanceInterface.create!(network: network, instance: instance, ip_address: ip_address)
      end

      # Selects the given channels for the given instance
      #
      # @param [Instance] instance
      # @param [Enumerable] channels
      # @return [undefined]
      def select_channels(instance, channels)
        channels.each do |channel|
          instance.channel_selections.push(select_channel(channel))
        end
      end

      # Creates a channel selection for the given channel
      #
      # SinglePortChannel(tcp) -> SinglePortChannelSelection(10343)
      # PortRangeChannel(udp, 10) -> PortRangeChannelSelection(20100, 20110)
      #
      # @param [Channel] channel
      # @return [ChannelSelection]
      def select_channel(channel)
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
      end
    end # AdaptationEngine
  end # Adaptor
end
