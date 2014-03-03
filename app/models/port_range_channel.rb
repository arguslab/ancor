class PortRangeChannel < Channel
  field :protocol, type: Symbol
  field :size, type: Integer

  field :number, type: Integer
end
