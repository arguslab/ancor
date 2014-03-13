class SinglePortChannel < Channel
  field :protocol, type: Symbol
  field :number, type: Integer

  validates :protocol, presence: true

  validates :number, numericality: { only_integer: true, greater_than: 0, less_than: 65536 },
  	if: Proc.new { |a| a.number? }

end