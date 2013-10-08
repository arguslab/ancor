class Role
  include Mongoid::Document

  field :name, type: String
  field :description, type: String
  field :slug, type: Symbol

  has_many :channels
  has_many :scenarios

  # Self-referencing many-to-many
  has_and_belongs_to_many :dependents, class_name: "Role", inverse_of: :dependencies
  has_and_belongs_to_many :dependencies, class_name: "Role", inverse_of: :dependents

  def dependent_instances
    dependents.map { |dependent_role|
      dependent_role.instances
    }.flatten
  end
end
