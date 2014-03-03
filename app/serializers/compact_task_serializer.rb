class CompactTaskSerializer < ActiveModel::Serializer
  attributes :id, :type, :arguments, :state, :created_at, :updated_at
end
