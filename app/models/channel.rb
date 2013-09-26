class Channel
  include Mongoid::Document

  field :name, type: String
  field :description, type: String
  field :slug, type: Symbol

  field :exporter_id, type: String
  field :importer_ids, type: Array
end
