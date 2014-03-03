class PublicIp
  include Mongoid::Document
  include Lockable
  include Providable

  field :ip_address, type: String
end
