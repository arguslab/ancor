class InstanceSerializer < CompactInstanceSerializer
  has_one :role, serializer: CompactRoleSerializer
end
