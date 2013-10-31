class SecurityGroupRule
  include Mongoid::Document

  embedded_in :group, class_name: "SecurityGroup", inverse_of: :rules

  field :cidr, type: String
  field :protocol, type: Symbol
  field :from, type: Integer
  field :to, type: Integer

  # Reserved for future use (ingress|egress)
  field :direction, type: Symbol, default: :ingress
end
