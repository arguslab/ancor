module Ancor
  module Tasks
    class DeployInstance < BaseExecutor
      def perform(instance_id)
        return unless task_completed(:create_secgroup) do
          create_task CreateSecurityGroup, instance_id
        end
      end

      def task_completed(key)
        k = key.to_s
        return false if store[k]

        store[k] = yield
        execute_task store[k]

        return true
      end

      def create_task(klass, *args)
        task = Task.create(type: klass, arguments: args)

        wh = WaitHandle.new(type: :task_completed)
        wh.parameters["task_id"] = task.id
        wh.tasks << context
        wh.save

        task.id.to_s
      end

      def execute_task(task_id)
        TaskWorker.perform_async(task_id)
      end
    end # DeployInstance
  end # Tasks
end
