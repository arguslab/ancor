module Ancor
  class TaskWorker
    include Sidekiq::Worker

    def perform(id)
      task = Task.find id

      klass = task.class_name.constantize
      # If this throws an exception, the task and its children stay in the database.
      # This could open up the possibility for automated recovery from errors.
      klass.new.perform *task.parameters

      task.children.each do |child|
        TaskWorker.perform_async child.id
      end

      task.delete
    end
  end
end
