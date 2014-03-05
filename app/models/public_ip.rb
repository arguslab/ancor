class PublicIp
  include Mongoid::Document
  include Lockable
  include Providable

  field :ip_address, type: String

  belongs_to :instance
  belongs_to :role
end
