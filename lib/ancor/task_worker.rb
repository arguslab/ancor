module Ancor
  class TaskWorker
    include Sidekiq::Worker

    def perform(task_id)
      task = find_and_lock task_id
      return unless task

      # Get the most recent state
      task.reload

      begin
        klass = task.type.constantize
        executor = klass.new
        executor.task = task

        unless execute_task task, executor
          # The task exited, but was not finished
          task.update_state :suspended
          return
        end
      rescue
        task.update_state :error
        raise
      end

      task.update_state :completed
      process_wait_handles :task_completed, task.id
    end

    private

    def execute_task(task, executor)
      executor.perform(*task.arguments)
    ensure
      task.save
    end

    def find_and_lock(task_id)
      loop do
        task = Task.find task_id

        if task.state == :completed
          # Task is already finished
          return false
        end

        if task.state == :in_progress
          # Sidekiq should requeue this task in ~15 seconds
          raise InvalidStateError
        end

        # changing from (pending|suspended|error) to in_progress
        if task.update_state :in_progress
          return task
        end

        # CAS failed, try again
      end
    end

    def process_wait_handles(type, task_id)
      criteria = {
        "type" => type,
        "parameters.task_id" => task_id
      }

      wait_tasks = WaitHandle.where(criteria).pluck(:task_ids).flatten.uniq
      wait_tasks.each do |wait_task_id|
        TaskWorker.perform_async wait_task_id.to_s
      end
    end
  end # Task Worker
end
