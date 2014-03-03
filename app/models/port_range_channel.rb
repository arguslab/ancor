class PortRangeChannel < Channel
  field :protocol, type: Symbol
  field :number, type: Integer
  field :size, type: Integer
end
