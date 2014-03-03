class SinglePortChannel < Channel
  field :protocol, type: Symbol
  field :port_no, type: Integer
end
