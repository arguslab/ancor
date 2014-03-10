class PortRangeChannelSelection < ChannelSelection
  field :from_port, type: Integer
  field :to_port, type: Integer

  def protocol
    channel.protocol
  end

  def to_hash
    {
      from_port: from_port,
      to_port: to_port,
      protocol: channel.protocol,
    }
  end
end
