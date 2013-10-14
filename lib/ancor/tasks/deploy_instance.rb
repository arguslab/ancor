module Ancor
  class DeployInstanceTask < BaseTask
    def perform(instance_id)
      unless store[:create_sg_id]
        sgtask_id = create_task("Ancor::CreateSecurityGroupTask", instance_id)
        store[:create_sg_id] = sgtask_id
        execute_task(sgtask_id)
        return false
      end
    end

    def create_task(klass, *args)
      task = Task.create(type: klass, arguments: args)

      wh = WaitHandle.new(type: :task_completed)
      wh.parameters[:task_id] = task.id
      wh.tasks << context
      wh.save

      task.id.to_s
    end

    def execute_task(task_id)
      TaskWorker.perform_async(task_id)
    end
  end # DeployInstanceTask
end
