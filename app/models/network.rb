class Network
  include Mongoid::Document
  include Lockable
  include Providable

  field :name, type: String

  field :cidr, type: String
  field :ip_version, type: Integer, default: 4
  field :dns_nameservers, type: Array

  field :last_ip, type: String

  has_many :connected_interfaces, class_name: "InstanceInterface"

  def instances
    connected_interfaces.map { |interface|
      interface.instance
    }
  end
end
