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

      # @return [Proc]
      attr_accessor :public_ip_builder

      def initialize
        @network_builder = proc {}
        @instance_builder = proc {}
        @public_ip_builder = proc {}
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
          instances = environment.roles.flat_map { |r| r.instances }
          networks = instances.flat_map { |i| i.networks }.uniq
          public_ips = instances.map { |i| i.public_ip }.compact

          puts "Deploying #{instances.count} instances"

          network_tasks = networks.map { |network|
            Task.create(type: Tasks::ProvisionNetwork.name, arguments: [network.id])
          }

          network_sink = sink_tasks(network_tasks)

          deploy_tasks = instances.map { |instance|
            Task.create(type: Tasks::DeployInstance.name, arguments: [instance.id])
          }

          network_sink.trigger(*deploy_tasks)

          allocate_tasks = public_ips.map { |public_ip|
            Task.create(type: Tasks::AllocatePublicIp.name, arguments: [public_ip.id])
          }

          deploy_sink = sink_tasks(deploy_tasks + allocate_tasks)

          associate_tasks = public_ips.map { |public_ip|
            Task.create(type: Tasks::AssociatePublicIp.name, arguments: [public_ip.id])
          }
          deploy_sink.trigger(*associate_tasks)
          associate_sink = sink_tasks(associate_tasks)

          # Unlock environment once all instances have been deployed
          unlock_task = Task.create(type: Tasks::UnlockEnvironment, arguments: [environment.id.to_s])
          associate_sink.trigger(unlock_task)

          (network_tasks + allocate_tasks).each do |task|
            TaskWorker.perform_async(task.id.to_s)
          end
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

          public_ips = environment.roles.flat_map { |r| r.public_ips }
          if public_ips.empty?
            instance_delete_sink.trigger(*network_delete_tasks)
            unlock_sink = sink_tasks(network_delete_tasks)
          else
            deallocate_tasks = public_ips.map { |public_ip|
              Task.create(type: Tasks::DeallocatePublicIp.name, arguments: [public_ip.id])
            }

            instance_delete_sink.trigger(*(network_delete_tasks + deallocate_tasks))
            unlock_sink = sink_tasks(network_delete_tasks + deallocate_tasks)
          end

          unlock_task = Task.create(type: Tasks::UnlockEnvironment, arguments: [environment.id])
          unlock_sink.trigger(unlock_task)

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

          unlock_task = Task.create(type: Tasks::UnlockEnvironment, arguments: [environment.id])

          if instance.public_ip
            allocate_task = Task.create(type: Tasks::AllocatePublicIp.name, arguments: [instance.public_ip.id])
            push_sink_task = sink_tasks(push_tasks + [allocate_task])

            associate_task = Task.create(type: Tasks::AssociatePublicIp.name, arguments: [instance.public_ip.id])
            push_sink_task.trigger(associate_task)
            associate_task.trigger(unlock_task)

            [instance_task, allocate_task].each do |task|
              TaskWorker.perform_async(task.id.to_s)
            end
          else
            push_sink_task = sink_tasks(push_tasks)
            push_sink_task.trigger(unlock_task)
            TaskWorker.perform_async(instance_task.id.to_s)
          end

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

        task_ids = tasks_to_sink.map { |task|
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
        assign_public_ip(instance, network)

        @instance_builder.call(instance)

        instance.save!
        instance
      end

      # @param [Instance] instance
      # @param [Network] network
      # @return [undefined]
      def assign_public_ip(instance, network)
        role = instance.role

        if role.public?
          public_ip = role.public_ips.find { |public_ip|
            !!public_ip.instance
          }

          unless public_ip
            public_ip = PublicIp.new
            public_ip.role = role
            @public_ip_builder.call(public_ip, instance, network)
          end

          instance.public_ip = public_ip
          public_ip.save
        end
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
          if channel.number
            SinglePortChannelSelection.new(channel: channel, port: channel.number)
          else
            SinglePortChannelSelection.new(channel: channel, port: rand(10_000..50_000))
          end
        when PortRangeChannel
          if channel.number
            from_port = channel.number
          else
            from_port = rand(10_000..50_000)
          end
          to_port = from_port + channel.size

          PortRangeChannelSelection.new(channel: channel, from_port: from_port, to_port: to_port)
        else
          raise ArgumentError
        end
      end
    end # AdaptationEngine
  end # Adaptor
end
