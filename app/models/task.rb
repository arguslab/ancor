class Task
  include Mongoid::Document
  include Stateful

  field :type, type: String
  field :parameters, type: Hash
  field :state, type: Symbol, default: :pending
end
