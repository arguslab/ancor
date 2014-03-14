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
    # Parallelizes multiple tasks into a single task sink
    #
    # @example Two tasks in parallel
    #   parallel do
    #     task ExampleTask
    #     task ExampleTask
    #   end
    #
    # @example Two chains of tasks in parallel
    #   parallel do
    #     chain do
    #       task ExampleTask
    #       task ExampleTask
    #     end
    #
    #     chain do
    #       task ExampleTask
    #       task ExampleTask
    #     end
    #   end
    class ParallelTaskBuilder < TaskBuilder
      # @return [Enumerable]
      attr_reader :heads

      # @return [Task]
      attr_reader :tail

      # @return [undefined]
      def initialize
        @heads = Array.new
        @tail = create_task(Tasks::Sink, Array.new)
      end

      # @return [Boolean]
      def empty?
        @heads.empty?
      end

      # @yield
      # @return [undefined]
      def chain(&block)
        builder = ChainTaskBuilder.build(&block)

        unless builder.empty?
          heads = builder.heads
          tail = builder.tail

          @heads.push(*heads)
          insert_task(tail)
        end
      end

      # @yield
      # @return [undefined]
      def parallel(&block)
        instance_exec(&block)
      end

      # @param [Class] type
      # @param [Object...] args
      # @return [undefined]
      def task(type, *args)
        task = create_task(type, *args)

        @heads.push(task)
        insert_task(task)
      end

      private

      # Appends the given task to the sink's list of tasks
      #
      # @param [Task] task
      # @return [undefined]
      def insert_task(task)
        @tail.arguments.first << task.id
        @tail.save

        task.trigger(@tail)
      end
    end # ParallelTaskBuilder
  end # Adaptor
end
