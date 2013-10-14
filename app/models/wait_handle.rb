class WaitHandle
  include Mongoid::Document

  field :type, type: Symbol
  field :parameters, type: Hash, default: -> { {} }

  has_and_belongs_to_many :tasks
end
