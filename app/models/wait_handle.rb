class WaitHandle
  include Mongoid::Document

  field :type, type: Symbol
  field :correlations, type: Hash, default: -> { {} }

  has_and_belongs_to_many :tasks

  before_save do
    self.correlations = self.class.normalize_hash correlations
  end

  def self.correlated_tasks(type, correlations = {})
    criteria = {
      type: type,
      correlations: normalize_hash(correlations)
    }

    where(criteria).pluck(:task_ids).flatten.uniq.map(&:to_s)
  end

  def self.each_task(type, correlations = {}, &block)
    correlated_tasks(type, correlations).each(&block)
  end

  private

  # Coerces all keys and values in the given hash to strings
  #
  # @param [Hash] h
  # @return [Hash]
  def self.normalize_hash(h)
    Hash[h.map { |k, v| [k.to_s, v.to_s] }]
  end
end
