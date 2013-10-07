class WaitHandle
  include Mongoid::Document

  field :type, type: Symbol
  field :parameters, type: Hash

  has_and_belongs_to_many :tasks
end
