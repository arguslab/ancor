# Used to track the change in count for model objects
#
# Note that this can only be used with objects or classes that have a
# consistent hash
class CountTracker
  # @param [Object...] sources
  # @return [undefined]
  def initialize(*sources)
    @sources = {}
    sources.each { |s| @sources[s] = s.count }
  end

  # @param [Object] source
  # @param [Integer] expectation
  # @return [Boolean]
  def has_change?(source, expectation)
    change(source) == expectation
  end

  # @param [Object] source
  # @return [Integer]
  def change(source)
    source.count - @sources.fetch(source)
  end

  def changes
    @sources.map { |source, count|
      source.count - count
    }
  end
end
