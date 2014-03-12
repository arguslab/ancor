class SinglePortChannel < Channel
  field :protocol, type: Symbol
  field :number, type: Integer

  #validates :protocol, presence: true, if: :valid_protocol?

 # validates :number, numericality: { only_integer: true, greater_than: 0, less_than: 65536 },
 #   unless: Proc.new { |a| a.number.blank? }

  #def valid_protocol?
  #	protocol == "tcp" or protocol == "udp" 
  #end

	#validates :number, numericality: { only_integer: true }

end
