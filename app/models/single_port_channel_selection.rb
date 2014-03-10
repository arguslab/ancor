class SinglePortChannelSelection < ChannelSelection
  field :port, type: Integer

  def protocol
    channel.protocol
  end

  def to_hash
    {
      port: port,
      protocol: channel.protocol,
    }
  end
end
