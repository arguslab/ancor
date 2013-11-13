class Scenario
  include Mongoid::Document

  field :name, type: String
  field :description, type: String
  field :slug, type: Symbol

  field :profile, type: String

  belongs_to :role
end
