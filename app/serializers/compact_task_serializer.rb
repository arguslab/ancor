class CompactTaskSerializer < ActiveModel::Serialzier
  attributes :id, :type, :arguments, :state
end
