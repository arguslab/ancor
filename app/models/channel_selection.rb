class ChannelSelection
  include Mongoid::Document

  field :instance_id, type: String
  field :channel_id, type: String
end
