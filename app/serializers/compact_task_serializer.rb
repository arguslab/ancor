class CompactTaskSerializer < ActiveModel::Serializer
  attributes :id, :type, :arguments, :state
end
