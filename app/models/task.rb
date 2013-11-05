class Task
  include Mongoid::Document
  include Ancor::Extensions::IndifferentAccess
  include Stateful

  field :type, type: String
  field :arguments, type: Array
  field :state, type: Symbol, default: :pending

  field :context, type: Hash, default: -> { {} }

  def completed?
    :completed == state
  end

  def error?
    :error == state
  end

  def pending?
    :pending == state
  end

  def suspended?
    :suspended == state
  end

  # Creates a wait handle that will trigger the given tasks when this task is completed
  #
  # @param [Task...] tasks
  # @return [undefined]
  def create_wait_handle(*tasks)
    wh = WaitHandle.new(type: :task_completed, correlations: { task_id: id })
    tasks.each { |task| wh.tasks << task }
    wh.save
  end
end
