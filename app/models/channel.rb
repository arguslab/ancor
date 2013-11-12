class Channel
  include Mongoid::Document

  field :name, type: String
  field :description, type: String
  field :slug, type: Symbol

  belongs_to :exporter, class_name: "Role", inverse_of: :exports
  has_and_belongs_to_many :importers, class_name: "Role", inverse_of: :imports

  validates :slug, presence: true
  validates :slug, uniqueness: { scope: :exporter_id }
end
