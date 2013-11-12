class Scenario
  include Mongoid::Document

  field :name, type: String
  field :description, type: String
  field :slug, type: Symbol

  field :data, type: String

  belongs_to :role

  embeds_many :stages, class_name: "ScenarioStage"

  def stage(slug)
    stages.find { |stage|
      stage.slug == slug
    }
  end
end
