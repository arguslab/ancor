class Fragment
  include Mongoid::Document

  field :name, type: String
  field :description, type: String
  field :slug, type: Symbol
end
