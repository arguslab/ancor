class Environment
  include Mongoid::Document
  include Lockable

  field :name, type: String
  field :description, type: String
  field :slug, type: Symbol

  has_many :roles
end
