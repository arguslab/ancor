class SecurityGroup
  include Mongoid::Document
  include Providable

  field :name, type: String

  has_and_belongs_to_many :instances

  embeds_many :rules, class_name: "SecurityGroupRule", inverse_of: :group
end
