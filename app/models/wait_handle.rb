class WaitHandle
  include Mongoid::Document

  field :type, type: Symbol
  field :parameters, type: Hash

  has_many :tasks
end
