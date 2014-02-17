module Ancor
  module Adaptor

    # Encapsulates the logic necessary for determining which instances can be used
    # to fulfill a dependency for a given instance
    class ImportSelector
      include Singleton

      # @param [Instance] target
      # @return [Hash]
      def select(target)
        role = target.role
        dependencies = role.dependencies

        resolved = {}
        dependencies.each { |dependency|
          resolved[dependency.slug] = resolve_instances target, dependency
        }

        resolved
      end

      private

      # @param [Instance] target
      # @param [Role] dependency
      # @return [Hash]
      def resolve_instances(target, dependency)
        instances = {}
        dependency.instances.each { |instance|
          next if instance.planned_stage == :undeploy

          ip_address = find_reachable_ip target, instance
          next unless ip_address

          channel_selections = map_channel_selections instance

          instances[instance.name] = {
            ip_address: ip_address,
            stage: instance.stage,
            planned_stage: instance.planned_stage,
          }.merge(channel_selections)
        }

        instances
      end

      # @param [Instance] target
      # @param [Instance] instance
      # @return [String]
      #   Returns false if instance is unreachable from the target
      def find_reachable_ip(target, instance)
        instance.interfaces.first.ip_address
      end

      # @param [Instance] instance
      # @return [Hash]
      def map_channel_selections(instance)
        Hash[instance.channel_selections.map { |selection|
          [selection.slug, selection.to_hash]
        }]
      end
    end

  end
end
