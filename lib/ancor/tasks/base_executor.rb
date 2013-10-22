module Ancor
  module Tasks
    class BaseExecutor
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

      # Creating a new dependent task and an associated wait hanlde
      #
      # @param [Class] klass
      # @param [Object...] args
      # @return [String] The identifier of the created task
      def create_task(klass, *args)
        dependent = Task.create(type: klass.name, arguments: args)

        wh = WaitHandle.new(type: :task_completed)
        wh.parameters["task_id"] = dependent.id
        wh.tasks << task
        wh.save

        dependent.id.to_s
      end

      # Enqueues the task with the given identifier into the Sidekiq queue
      #
      # @param [String] task_id
      # @return [undefined]
      def execute_task(task_id)
        TaskWorker.perform_async(task_id)
      end
    end # BaseExecutor
  end # Tasks
end
