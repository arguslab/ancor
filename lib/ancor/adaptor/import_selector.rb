# Author: Ian Unruh, Alexandru G. Bardas
# Copyright (C) 2013-2014 Argus Cybersecurity Lab, Kansas State University
#
# This file is part of ANCOR.
#
# ANCOR is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ANCOR is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with ANCOR.  If not, see <http://www.gnu.org/licenses/>.
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
