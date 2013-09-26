class ScenarioPart
  include Mongoid::Document

  field :scenario_id, type: String
  field :slug, type: Symbol

  field :stage, type: Symbol

  field :data_url, type: String
end
