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

        @next_ip = 10
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
        ip_address = network.cidr.split("0/24")[0] + @next_ip.to_s
        @next_ip += 1

        instance = Instance.new
        # DNS names can't have underscores T_T
        instance.name = "#{role.slug}#{index}".gsub "_", "-"
        instance.role = role
        instance.scenario = role.scenarios.first
        instance.planned_stage = :deploy

        role.exports.each do |channel|
          instance.channel_selections.push(select_channel(channel))
        end

        @instance_builder.call(instance)

        instance.save!

        interface = InstanceInterface.create!(network: network, instance: instance, ip_address: ip_address)

        instance
      end

      # Creates a channel selection for the given channel
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
