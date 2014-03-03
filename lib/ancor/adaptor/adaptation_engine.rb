require 'ipaddress'

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
      end

      # Queries the requirement model and creates a suitable system model
      #
      # @raise [LockAcquisitionError]
      # @param [Environment] environment
      # @return [undefined]
      def plan(environment)
        environment.synchronized do

          network = build_network
          instances = []

          Role.all.each do |role|
            role.min.times do |index|
              instances.push(build_instance(index, network, role))
            end
          end

        end
      end

      # Starts the deployment of planned networks and instances
      #
      # This method call is asynchronous
      #
      # 1. Locks the environment
      # 2. Provisions the network
      # 3. Deploys the instances
      # 4. Unlocks the environment
      #
      # @raise [LockAcquisitionError]
      # @param [Environment] environment
      # @return [undefined]
      def commit(environment)
        environment.lock

        begin
          network = Network.first

          instances = Instance.all
          puts "Deploying #{instances.count} instances"

          network_task = Task.create(type: Tasks::ProvisionNetwork.name, arguments: [network.id])

          deploy_tasks = instances.map { |instance|
            Task.create(type: Tasks::DeployInstance.name, arguments: [instance.id])
          }

          network_task.trigger(*deploy_tasks)

          deploy_sink = sink_tasks(deploy_tasks)

          # Unlock environment once all instances have been deployed
          unlock_task = Task.create(type: Tasks::UnlockEnvironment, arguments: [environment.id.to_s])
          deploy_sink.trigger(unlock_task)

          TaskWorker.perform_async(network_task.id.to_s)
        rescue => ex
          # Something went wrong, unlock the environment immediately
          environment.unlock
          raise ex
        end
      end

      # @raise [LockAcquisitionError]
      # @param [Environment] environment
      # @return [undefined]
      def destroy(environment)
        environment.lock

        begin
          instances = environment.roles.flat_map { |r| r.instances }
          instance_delete_tasks = instances.map { |instance|
            Task.create(type: Tasks::DeleteInstance.name, arguments: [instance.id])
          }

          instance_delete_sink = sink_tasks(instance_delete_tasks)

          networks = instances.flat_map { |i| i.networks }.uniq
          network_delete_tasks = networks.map { |network|
            Task.create(type: Tasks::DeleteNetwork.name, arguments: [network.id])
          }

          instance_delete_sink.trigger(*network_delete_tasks)

          network_delete_sink = sink_tasks(network_delete_tasks)

          unlock_task = Task.create(type: Tasks::UnlockEnvironment, arguments: [environment.id])
          network_delete_sink.trigger(unlock_task)

          instance_delete_tasks.each do |task|
            TaskWorker.perform_async(task.id.to_s)
          end
        rescue => ex
          environment.unlock
          raise ex
        end
      end

      # Adds an instance for the given role
      #
      # This method call is asynchronous
      #
      # 1. Locks the environment
      # 2. Deploys an instance
      # 3. Pushes configuration to affected instances
      # 4. Unlocks the environment
      #
      # @raise [LockAcquisitionError]
      # @param [Symbol] role_slug
      # @return [undefined]
      def add_instance(role_slug)
        role = Role.find_by(slug: role_slug)
        environment = role.environment

        environment.lock

        begin
          network = Network.first

          instance = build_instance(rand(100..10000), network, role)
          instance_task = Task.create(type: Tasks::DeployInstance.name, arguments: [instance.id])

          puts "Planning to deploy instance #{instance.name}"

          push_tasks = role.dependent_instances.map { |ai|
            puts "Planning push configuration for instance #{ai.name}"
            Task.create(type: Tasks::PushConfiguration.name, arguments: [ai.id])
          }

          instance_task.trigger(*push_tasks)

          push_sink_task = sink_tasks(push_tasks)

          # Unlock environment once affected instances have been updated
          unlock_task = Task.create(type: Tasks::UnlockEnvironment, arguments: [environment.id])
          push_sink_task.trigger(unlock_task)

          TaskWorker.perform_async(instance_task.id.to_s)
        rescue => ex
          # Something went wrong, unlock the environment immediately
          environment.unlock
          raise ex
        end
      end

      # Removes a given instance
      #
      # This method call is asynchronous
      #
      # 1. Locks the environment
      # 2. Marks instance for undeploy
      # 3. Pushes configuration to affected instances
      # 4. Deletes the instance
      # 5. Unlocks the enviroment
      #
      # @raise [LockAcquisitionError]
      # @param [String] instance_id
      # @return [undefined]
      def remove_instance(instance_id)
        instance = Instance.find instance_id
        role = instance.role
        environment = role.environment

        environment.lock

        begin
          puts "Planning to undeploy instance #{instance.name}"

          instance.planned_stage = :undeploy
          instance.save

          push_tasks = role.dependent_instances.map { |ai|
            puts "Planning push configuration for instance #{ai.name}"
            Task.create(type: Tasks::PushConfiguration.name, arguments: [ai.id])
          }

          push_sink_task = sink_tasks(push_tasks)

          delete_task = Task.create(type: Tasks::DeleteInstance.name, arguments: [instance.id])
          push_sink_task.trigger(delete_task)

          # Unlock environment once instance is deleted
          unlock_task = Task.create(type: Tasks::UnlockEnvironment, arguments: [environment.id])
          delete_task.trigger(unlock_task)

          push_tasks.each do |task|
            TaskWorker.perform_async(task.id.to_s)
          end
        rescue => ex
          # Something went wrong, unlock the environment
          environment.unlock
          raise ex
        end
      end

      private

      def sink_tasks(tasks_to_sink)
        sink_task = Task.new(type: Tasks::Sink.name)

        ids = tasks_to_sink.map { |task|
          task.trigger(sink_task)
          task.id.to_s
        }

        sink_task.arguments = [task_ids]
        sink_task.save

        sink_task
      end

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
        block = IPAddress.parse(network.cidr)

        if network.last_ip
          last_ip = IPAddress.parse(network.last_ip)
          last_ip = IPAddress::IPv4.parse_u32(last_ip.to_u32 + 3)
        else
          last_ip = IPAddress::IPv4.parse_u32(block.to_u32 + 10)
        end

        unless block.include?(last_ip)
          raise "Instance IP address out of range of network block"
        end

        network.last_ip = last_ip.address
        network.save

        InstanceInterface.create!(network: network, instance: instance, ip_address: last_ip.address)
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
          if valid_port_input(channel.port_no) then
            SinglePortChannelSelection.new(channel: channel, port: channel.port_no)
          else
            SinglePortChannelSelection.new(channel: channel, port: rand(10_000..50_000))
          end
        when PortRangeChannel
          to_port = channel.from_port + channel.size
          if valid_port_input(channel.from_port) && valid_port_input(to_port) then
            PortRangeChannelSelection.new(channel: channel, from_port: channel.from_port, to_port: to_port)
          end
        else
          raise ArgumentError
        end
      end

      def valid_port_input(port)
        if !port.nil? && (port.is_a? Integer) && port.between?(1,65535) then
          return true
        else
          return false
        end
      end
    end # AdaptationEngine
  end # Adaptor
end
