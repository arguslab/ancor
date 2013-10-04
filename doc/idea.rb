


class DeployInstanceTask
  def perform(instance_id)
    unless status[:started]
      # TODO somehow submit tasks here

      add_dependent_task(push conf task id)
      add_dependent_task(update group task id)

      status[:started] = true

      add_wait_condition_for_dependent_tasks

      leave_task
    end


    unless dependent_tasks_finished
      leave_task
    end

    # We're finished
  end
end
