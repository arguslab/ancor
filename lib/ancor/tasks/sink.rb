module Ancor
  module Tasks
    class Sink < BaseExecutor
      def perform(task_ids)
        remaining = task_ids.reject { |id| Task.find(id).state == :completed }
        if remaining.empty?
          puts "Task sink complete"
          true
        else
          puts "Task sink incomplete, waiting on #{remaining.join(', ')}"
          false
        end
      end
    end
  end
end
