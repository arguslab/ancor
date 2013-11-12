class ChannelSelection
  include Mongoid::Document

  embedded_in :instance
  belongs_to :channel

  validates :channel, presence: true

  def slug
    channel.slug
  end
end
