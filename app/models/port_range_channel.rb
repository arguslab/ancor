class PortRangeChannel < Channel
  field :protocol, type: Symbol
  field :size, type: Integer

  field :number, type: Integer

#  validates :size, numericality: { only_integer: true, greater_than: 0, less_than: 65535}
end
