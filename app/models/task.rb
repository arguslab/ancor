require 'ancor/extensions/mash'

class Task
  include Mongoid::Document
  include Stateful

  field :type, type: String
  field :arguments, type: Array
  field :state, type: Symbol, default: :pending

  field :context, type: Hash, default: -> { {} }
end
