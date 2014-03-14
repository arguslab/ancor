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
  module Tasks
    class BaseExecutor
      include Loggable
      include Operational

      # @return [Task]
      attr_accessor :task

      # State of the task that is persisted between task executions
      # in the database
      # @return [Hash]
      def context
        @task.context
      end

      # @abstract
      # @param [Object...] arguments
      # @return [Boolean]
      #   Returns true if the executor finished
      #   Returns false if the executor will be resumed later
      def perform(*)
        raise NotImplementedError
      end

      private

      # Returns true if the the given key is set in the context of the task
      #
      # @param [Symbol] key
      # @return [Boolean]
      def task_started?(key)
        context.key?(key.to_s)
      end

      # Returns true if the dependent task stored in the context was completed
      #
      # @param [Symbol] key
      # @return [Boolean]
      def task_completed?(key)
        Task.find(context[key.to_s]).state == :completed
      end

      # Store dependent task in the context of the main task and pass the dependent
      # task to be executed
      #
      # @param [Symbol] key
      # @param [Class] klass
      # @param [Object...] args
      # @return [undefined]
      def perform_task(key, klass, *args)
        k = key.to_s
        task_id = create_task klass, *args
        context[k] = task_id
        execute_task task_id
      end

      # Creates a new task and wait handle that is associated with this task
      #
      # @param [Class] klass
      # @param [Object...] args
      # @return [String] The identifier of the created task
      def create_task(klass, *args)
        dependent = Task.create(type: klass.name, arguments: args).id.to_s

        create_wait_handle(:task_completed, task_id: dependent)
        dependent
      end

      # Creates a new wait handle and associates it with this task
      #
      # @param [Symbol] type
      # @param [Hash] correlations
      # @return [undefined]
      def create_wait_handle(type, correlations)
        wh = WaitHandle.new(type: type, correlations: correlations)
        wh.tasks << task
        wh.save
      end

      # Enqueues the task with the given identifier into the Sidekiq queue
      #
      # @param [String] task_id
      # @return [undefined]
      def execute_task(task_id)
        TaskWorker.perform_async(task_id)
      end

      def ensure_task_chain(task_definitions)
        task_definitions.each do |task|
          key, task_type, *args = *task

          unless context["#{key}_finished"]
            unless task_started? key
              perform_task key, task_type, *args
              return false
            end

            return false unless task_completed? key
            context["#{key}_finished"] = true
          end
        end

        true
      end
    end # BaseExecutor
  end # Tasks
end
