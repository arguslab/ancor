class SinglePortChannelSelection < ChannelSelection
  field :port, type: Integer

  def to_hash
    {
      port: port,
      protocol: channel.protocol,
    }
  end
end
