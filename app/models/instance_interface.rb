class InstanceInterface
  include Mongoid::Document

  field :instance_id, type: String
  field :network_id, type: String

  field :ip_address, type: String

  def instance
    Instance.find instance_id
  end

  def network
    Network.find network_id
  end
end
