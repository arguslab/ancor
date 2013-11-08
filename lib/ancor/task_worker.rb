module Ancor
  class TaskWorker
    include Sidekiq::Worker

    def perform(task_id)
      task = Task.find(task_id)
      task.lock(jid) unless task.locked?(jid)

      begin
        unless task.completed?
          execute_task task
          process_wait_handles :task_completed, task.id
        end
      ensure
        task.unlock(jid)
      end
    end

    private

    # @raise [Exception] If an error occured during execution
    # @param [Task] task
    # @return [undefined]
    def execute_task(task)
      executor = task.type.constantize.new
      executor.task = task

      task.update_state :in_progress

      begin
        if executor.perform(*task.arguments)
          task.update_state :completed
        else
          task.update_state :suspended
        end
      rescue
        task.update_state :error
        raise
      ensure
        # Ensure task context is persisted
        task.save
      end
    end

    def process_wait_handles(type, task_id)
      WaitHandle.each_task(type, task_id: task_id) do |id|
        TaskWorker.perform_async id
      end
    end
  end # TaskWorker
end
