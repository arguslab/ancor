class ProviderEndpoint
  include Mongoid::Document

  field :name, type: String
  field :slug, type: Symbol
  field :description, type: String

  # Could be :os_neutron, :os_nova, :aws
  field :type, type: Symbol

  field :options, type: Hash, default: -> { {} }
end
