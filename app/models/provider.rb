class Provider
  include Mongoid::Document

  field :name, type: String
  field :slug, type: Symbol
  field :description, type: String

  field :type, type: Symbol

  field :connection, type: Hash, default: -> { {} }
end
