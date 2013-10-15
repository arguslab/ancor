module Ancor
  module Tasks
    class BaseExecutor
      # @return [Task]
      attr_accessor :task

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

      # @param [Symbol] key
      # @return [Boolean]
      def task_started?(key)
        context.key?(key.to_s)
      end

      # @param [Symbol] key
      # @return [Boolean]
      def task_completed?(key)
        Task.find(context[key.to_s]).state == :completed
      end

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

      # @param [Class] klass
      # @param [Object...] args
      # @return [String] The identifier of the created task
      def create_task(klass, *args)
        task = Task.create(type: klass.name, arguments: args)

        wh = WaitHandle.new(type: :task_completed)
        wh.parameters["task_id"] = task.id
        wh.tasks << context
        wh.save

        task.id.to_s
      end

      # Puts the given task in the Sidekiq queue
      #
      # @param [String] task_id
      # @return [undefined]
      def execute_task(task_id)
        TaskWorker.perform_async(task_id)
      end
    end # BaseExecutor
  end # Tasks
end
