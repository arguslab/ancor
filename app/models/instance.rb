class Instance
  include Mongoid::Document
  include Lockable
  include Providable

  STAGES = [
    :setup,
    :configure,
    :deploy,
    :undeploy,
  ]

  SPECIAL_STAGES = [
    :error,
    :undefined,
  ]

  field :name, type: String

  field :stage, type: Symbol, default: :undefined
  field :planned_stage, type: Symbol, default: :undefined

  belongs_to :role
  belongs_to :scenario

  has_one :public_ip, dependent: :nullify

  has_many :interfaces, class_name: "InstanceInterface"

  has_and_belongs_to_many :security_groups

  embeds_many :channel_selections

  validates :name, presence: true

  def networks
    interfaces.map { |interface|
      interface.network
    }
  end
end
