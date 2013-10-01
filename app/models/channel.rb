class Channel
  include Mongoid::Document

  field :name, type: String
  field :description, type: String
  field :slug, type: Symbol

  belongs_to :role
end
