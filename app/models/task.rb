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
end
