module Ancor
  class DeployInstanceTask < BaseTask
    def perform(instance_id)

      puts "Entered DeployInstanceTask"

      unless state[:create_sg_id]
        puts "Security group not created yet, adding task to DB"

        task = create_task("Ancor::CreateSecurityGroupTask", instance_id)
        state[:create_sg_id] = task.id

        puts "Submitting security group task to Sidekiq"
        execute_task(task)

        puts "Suspending task"
        return false
      end

      puts "Finished DeployInstanceTask"

    end

    def create_task(klass, *args)
      Task.create(type: klass, arguments: args)
    end

    def execute_task(task)
      TaskWorker.perform_async(task.id.to_s)
    end
  end # DeployInstanceTask
end
