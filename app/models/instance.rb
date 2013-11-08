class Instance
  include Mongoid::Document
  include Lockable
  include Providable

  LIFECYCLE_STAGES = [
    :deploy,
    :prepare_undeploy,
    :undeploy
  ]

  field :name, type: String

  field :lifecycle_stage, type: Symbol, default: :deploy

  belongs_to :role
  belongs_to :scenario

  has_many :interfaces, class_name: "InstanceInterface"

  has_and_belongs_to_many :security_groups

  def networks
    interfaces.map do |interface|
      interface.network
    end
  end

  def usable?
    :deploy == lifecycle_stage
  end
end
