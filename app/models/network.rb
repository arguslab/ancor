class Network
  include Mongoid::Document
  include Providable
  include Stateful

  field :name, type: String

  field :cidr, type: String
  field :ip_version, type: Integer, default: 4

  field :state, type: Symbol, default: :planned
end
