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

      # Adds an instance for the given role
      #
      # @param [Symbol] role_slug
      # @return [undefined]
      def add_instance(role_slug)
        role = Role.find_by(slug: role_slug)

        network = Network.first

        instance = build_instance(rand(100..10_000), network, role)
        instance_task = Task.create(type: Tasks::DeployInstance.name, arguments: [instance.id])

        puts "Planning to deploy instance #{instance.name}"

        push_tasks = role.dependent_instances.map { |ai|
          puts "Planning push configuration for instance #{ai.name}"
          Task.create(type: Tasks::PushConfiguration.name, arguments: [ai.id])
        }

        instance_task.create_wait_handle(*push_tasks)

        TaskWorker.perform_async(instance_task.id.to_s)
      end

      # Removes an instance for the given role
      #
      # @param [Symbol] role_slug
      # @return [undefined]
      def remove_instance(role_slug)
        role = Role.find_by(slug: role_slug)
        instance = role.instances.find_by(planned_stage: :deploy)

        puts "Planning to undeploy instance #{instance.name}"

        instance.planned_stage = :undeploy
        instance.save

        sink_task = Task.new(type: Tasks::Sink.name)

        push_tasks = role.dependent_instances.map { |ai|
          puts "Planning push configuration for instance #{ai.name}"
          Task.create(type: Tasks::PushConfiguration.name, arguments: [ai.id]).tap { |t|
            t.create_wait_handle(sink_task)
          }
        }

        task_ids = push_tasks.map { |t| t.id.to_s }

        sink_task.arguments = [task_ids]
        sink_task.save

        delete_task = Task.create(type: Tasks::DeleteInstance.name, arguments: [instance.id])
        sink_task.create_wait_handle(delete_task)

        task_ids.each do |id|
          TaskWorker.perform_async(id)
        end
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
        instance.planned_stage = :deploy

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
