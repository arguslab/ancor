class Role
  include Mongoid::Document

  field :name, type: String
  field :description, type: String
  field :slug, type: Symbol

  has_and_belongs_to_many :imports, class_name: "Channel", inverse_of: :importers
  has_many :exports, class_name: "Channel", inverse_of: :exporter
  has_many :scenarios

  def dependent_instances
    # Channel -> Role -> Instance
    exports.map { |channel|
      channel.importers.map { |role|
        role.instances
      }
    }.flatten.compact
  end
end
