class CompactRoleSerializer < ActiveModel::Serializer
  attributes :id, :slug, :name, :description

  has_one :environment, serializer: CompactEnvironmentSerializer
end
