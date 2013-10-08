require 'ancor/extensions/mash'

class Task
  include Mongoid::Document
  include Stateful

  field :type, type: String
  field :parameters, type: Hash
  field :state, type: Symbol, default: :pending

  field :store, type: Hashie::Mash, default: -> { Hashie::Mash.new }
end
