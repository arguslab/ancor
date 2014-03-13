class Role
  include Mongoid::Document

  field :name, type: String
  field :description, type: String
  field :slug, type: Symbol

  field :min, type: Integer, default: 1
  field :max, type: Integer

  field :is_public, type: Boolean, default: false
  alias_method :public?, :is_public

  belongs_to :environment

  has_many :public_ips

  has_many :scenarios, autosave: true

  has_many :exports, class_name: "Channel", inverse_of: :exporter, autosave: true
  has_and_belongs_to_many :imports, class_name: "Channel", inverse_of: :importers, autosave: true

  has_many :instances

  validates :slug, presence: true

  validates :min, numericality: { only_integer: true, greater_than: 0 }

  validates :max, numericality: { only_integer: true, greater_than_or_equal_to: 1 },
    if: :validate_max

  def validate_max
    unless max? and min <= max
      errors.add(:max, "should be an integer >=1 and cannot be less than min (in this case: min: #{min} and max: #{max})") 
    end
  end

  def dependencies
    imports.map { |channel|
      channel.exporter
    }.uniq
  end

  def dependent_roles
    exports.map { |channel|
      channel.importers
    }.flatten.uniq
  end

  def dependent_instances
    dependent_roles.map { |role|
      role.instances
    }.flatten
  end
end
