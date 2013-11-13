class Goal
  include Mongoid::Document

  field :name, type: String
  field :description, type: String
  field :slug, type: Symbol

  has_and_belongs_to_many :roles, autosave: true
end
