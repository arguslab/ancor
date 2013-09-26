class Instance
  include Mongoid::Document
  include Providable

  LIFECYCLE_STAGES = [
    :deploy,
    :prepare_undeploy,
    :undeploy
  ]

  field :role_id
  field :scenario_id

  field :name, type: String
  field :status, type: Symbol, default: :absent

  field :lifecycle_stage, type: Symbol, default: :deploy

  def interfaces
    InstanceInterface.where(instance_id: id).all
  end

  def role
    Role.find role_id
  end

  def scenario
    Scenario.find scenario_id
  end

  def usable?
    :deploy == lifecycle_stage
  end
end
