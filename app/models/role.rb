class Role
  include Mongoid::Document

  field :name, type: String
  field :description, type: String
  field :slug, type: Symbol

  field :min, type: Integer, default: 1
  field :max, type: Integer

  has_many :scenarios

  has_and_belongs_to_many :imports, class_name: "Channel", inverse_of: :importers
  has_many :exports, class_name: "Channel", inverse_of: :exporter

  has_many :instances

  validates :slug, presence: true

  def dependencies
    imports.map { |channel|
      channel.exporter
    }.uniq
  end

  def dependent_roles
    exports.map { |channel|
      channel.importers
    }.flatten.uniq
  end

  def dependent_instances
    dependent_roles.map { |role|
      role.instances
    }.flatten
  end
end
