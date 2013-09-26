class Network
  include Mongoid::Document
  include Providable

  field :name, type: String

  field :cidr, type: String
  field :ip_version, type: Integer, default: 4

  field :status, type: Symbol, default: :absent

  validates :cidr, uniqueness: true
end
