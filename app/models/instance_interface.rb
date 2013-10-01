class InstanceInterface
  include Mongoid::Document

  field :ip_address, type: String

  belongs_to :network
  belongs_to :instance
end
