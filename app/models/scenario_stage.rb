class ScenarioStage
  include Mongoid::Document

  embedded_in :scenario

  field :slug, type: Symbol
  field :description, type: String

  field :profiles, type: Array
end
