class Network
  include Mongoid::Document
  include Providable
  include Stateful

  field :name, type: String

  field :cidr, type: String
  field :ip_version, type: Integer, default: 4
  field :dns_nameservers, type: Array

  field :state, type: Symbol, default: :planned

  has_many :connected_interfaces, class_name: "InstanceInterface"
end
