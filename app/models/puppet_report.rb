class PuppetReport
  include Mongoid::Document

  belongs_to :instance

  field :transaction_uuid, type: String
  field :started_at, type: Time
  field :status, type: Symbol

  def fail?
    :failed == status
  end

  def success?
    :unchanged == status || :changed == status
  end
end
