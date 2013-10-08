class WaitHandle
  include Mongoid::Document

  field :type, type: Symbol
  field :parameters, type: Hashie::Mash, default: -> { Hashie::Mash.new }

  has_and_belongs_to_many :tasks
end
