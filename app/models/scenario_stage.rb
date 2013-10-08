class ScenarioStage
  include Mongoid::Document

  embedded_in :scenario

  field :slug, type: Symbol
  field :description, type: String

  # Uni-directional many-to-many
  has_and_belongs_to_many :fragments
end
