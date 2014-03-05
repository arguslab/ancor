class CompactInstanceSerializer < ActiveModel::Serializer
  attributes :id, :name, :stage, :planned_stage

  has_one :public_ip, serializer: PublicIpSerializer
  has_many :interfaces, serializer: InstanceInterfaceSerializer
end
