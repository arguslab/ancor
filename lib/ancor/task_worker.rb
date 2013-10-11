module Ancor
  class TaskWorker
    include Sidekiq::Worker

    def perform(task_id)
      task = find_and_lock task_id
      return unless task

      begin
        klass = task.type.constantize
        instance = klass.new
        instance.state = task.state

        unless instance.perform(*task.arguments)
          # The task exited, but was not finished
          task.update_state :suspended
          return
        end
      rescue
        # TODO Log the error
        raise

        task.update_state :error
        process_wait_handles :task_failed, task_id

        return
      end

      task.update_state :completed
      process_wait_handles :task_completed, task_id
    end

    private

    def find_and_lock(task_id)
      loop do
        task = Task.find task_id

        if [:error, :completed].include? task.state
          # Task is already finished
          return false
        end

        if task.state == :in_progress
          # Sidekiq should requeue this task in ~15 seconds
          raise InvalidStateError
        end

        # changing from (pending|suspended) to in_progress
        if task.update_state :in_progress
          return task
        end

        # CAS failed, try again
      end
    end

    def process_wait_handles(type, task_id)
      criteria = {
        "type" => type,
        "parameters.task_id" => Moped::BSON::ObjectId.from_string(task_id)
      }

      tasks = WaitHandle.where(criteria).pluck(:task_ids).flatten.uniq
      tasks.each do |task|
        TaskWorker.perform_async task.id
      end
    end
  end # Task Worker
end
