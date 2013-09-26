class Scenario
  include Mongoid::Document

  field :name, type: String
  field :description, type: String
  field :slug, type: Symbol

  field :role_id, type: String

  def role
    Role.find role_id
  end
end
