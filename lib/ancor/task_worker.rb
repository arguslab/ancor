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
          interval = rand 1..15

          # Requeue this task for processing in 1-10 seconds
          TaskWorker.perform_in(interval, task_id)
          return false
        end

        # changing from (pending|suspended|error) to in_progress
        if task.update_state :in_progress
          return task
        end

        # CAS failed, try again
      end
    end

    def process_wait_handles(type, task_id)
      WaitHandle.tasks_for(type, task_id: task_id).each do |id|
        TaskWorker.perform_async id
      end
    end
  end # TaskWorker
end
