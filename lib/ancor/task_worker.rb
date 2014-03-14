# Author: Ian Unruh, Alexandru G. Bardas
# Copyright (C) 2013-2014 Argus Cybersecurity Lab, Kansas State University
#
# This file is part of ANCOR.
#
# ANCOR is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ANCOR is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with ANCOR.  If not, see <http://www.gnu.org/licenses/>.
module Ancor
  class TaskWorker
    include Sidekiq::Worker

    def perform(task_id)
      task = Task.find(task_id)

      return if task.completed?

      task.lock
      begin
        execute_task(task)
      ensure
        task.unlock
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
          process_wait_handles(:task_completed, task.id)
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
