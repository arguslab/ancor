class Scenario
  include Mongoid::Document

  field :name, type: String
  field :description, type: String
  field :slug, type: Symbol

  belongs_to :role

  embeds_many :stages, class_name: "ScenarioStage"
end
