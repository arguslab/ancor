class PortRangeChannel < Channel
  field :protocol, type: Symbol
  field :size, type: Integer

  field :number, type: Integer

  validates :protocol, presence: true
	validates :size,  presence: true, numericality: { 
																			only_integer: true, 
																			greater_than_or_equal_to: 0, 
																			less_than: 65536 }

  validates :number, numericality: { only_integer: true, greater_than: 0, less_than: 65536 },
  	if: :within_range

  def within_range
  	errors.add(:within_range, "(port number + size) should be less or equal to 65535") unless number? and (number + size) <= 65535
  end
end #PortRangeChannel