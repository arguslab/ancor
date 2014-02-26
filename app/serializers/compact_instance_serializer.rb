class CompactInstanceSerializer < ActiveModel::Serializer
  attributes :id, :name, :stage, :planned_stage
end
