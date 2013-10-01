class Instance
  include Mongoid::Document
  include Providable

  LIFECYCLE_STAGES = [
    :deploy,
    :prepare_undeploy,
    :undeploy
  ]

  field :name, type: String
  field :status, type: Symbol

  field :lifecycle_stage, type: Symbol, default: :deploy

  belongs_to :role
  belongs_to :scenario

  has_many :interfaces, class_name: "InstanceInterface"

  def networks
    interfaces.map do |interface|
      interface.network
    end
  end

  def usable?
    :deploy == lifecycle_stage
  end
end
