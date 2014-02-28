class EnvironmentSerializer < CompactEnvironmentSerializer
  has_many :roles, serializer: CompactRoleSerializer
end
