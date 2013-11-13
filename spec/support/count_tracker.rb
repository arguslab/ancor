# Used to track the change in count for model objects
class CountTracker
  # @param [Class...] sources
  # @return [CountTracker]
  def self.start(*sources)
    tracker = new(*sources)
    tracker.capture

    tracker
  end

  # @param [Class...] sources
  # @return [undefined]
  def initialize(*sources)
    @sources = sources
    @counts = {}
  end

  # @return [undefined]
  def capture
    @counts = Hash[@sources.map { |source|
      [source.name, source.count]
    }]
  end

  # @param [Class] source
  # @return [Integer]
  def difference(source)
    source.count - @counts.fetch(source.name)
  end

  alias_method :[], :difference

  # @return [Integer]
  def all
    @sources.reduce(0) { |sum, x| sum + difference(x) }
  end
end
