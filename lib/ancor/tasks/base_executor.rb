module Ancor
  module Tasks
    class BaseExecutor
      # @return [Task]
      attr_accessor :task

      def context
        @task.context
      end

      # @param [Object...] arguments
      # @return [Boolean]
      #   Returns true if the executor finished
      #   Returns false if the executor will be resumed later
      def perform(*)
        raise NotImplementedError
      end

      private

      def task_completed?(key)
        k = key.to_s

        if context[k]
          Task.find(context[k]).state == :completed
        else
          false
        end
      end

      def perform_task(key, klass, *args)
        k = key.to_s
        task_id = create_task klass, *args
        context[k] = task_id
        execute_task task_id
      end

      def create_task(klass, *args)
        task = Task.create(type: klass.name, arguments: args)

        wh = WaitHandle.new(type: :task_completed)
        wh.parameters["task_id"] = task.id
        wh.tasks << context
        wh.save

        task.id.to_s
      end

      def execute_task(task_id)
        TaskWorker.perform_async(task_id)
      end
    end # BaseExecutor
  end # Tasks
end
