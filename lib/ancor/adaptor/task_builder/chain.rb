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
    # Serializes multiple tasks into a single chain
    #
    # @example Two tasks in a chain
    #   chain do
    #     task ExampleTask
    #     task ExampleTask
    #   end
    #
    # @example Two sets of parallel tasks in a chain
    #   chain do
    #     parallel do
    #       task ExampleTask
    #       task ExampleTask
    #     end
    #
    #     parallel do
    #       task ExampleTask
    #       task ExampleTask
    #     end
    #   end
    class ChainTaskBuilder < TaskBuilder
      # @return [Enumerable]
      attr_reader :heads

      # @return [Enumerable]
      attr_reader :tail

      # @return [Boolean]
      def empty?
        @heads.nil? || @heads.empty?
      end

      # @param [Class] type
      # @param [Object...] args
      # @return [undefined]
      def task(type, *args)
        task = create_task(type, *args)
        insert_task(task)
        @tail = task
      end

      # @yield
      # @return [undefined]
      def chain(&block)
        instance_exec(&block)
      end

      # @yield
      # @return [undefined]
      def parallel(&block)
        builder = ParallelTaskBuilder.build(&block)

        unless builder.empty?
          insert_task(*builder.heads)
          @tail = builder.tail
        end
      end

      private

      # @param [Task...] args
      # @return [undefined]
      def insert_task(*args)
        if @heads
          @tail.trigger(*args)
        else
          @heads = args
        end
      end
    end # ChainTaskBuilder
  end # Adaptor
end
