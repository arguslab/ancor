module Ancor
  # Thread-safe copy-on-write list, suitable when reads outnumber writes by a wide margin
  class ConcurrentList
    extend Forwardable
    include Enumerable

    def initialize
      @mutex = Mutex.new
      @elements = []
    end

    def clear
      update do |elements|
        elements.clear
      end
    end

    def delete(element)
      update do |elements|
        elements.delete element
      end
    end

    def each(&block)
      @elements.each(&block)
    end

    def empty?
      @elements.empty?
    end

    def include?(element)
      @elements.include?(element)
    end

    def push(element)
      update do |elements|
        elements.push element
      end
    end

    alias_method :<<, :push

    def size
      @elements.size
    end

    def to_a
      @elements.dup
    end

    private

    def update
      @mutex.synchronize do
        update = @elements.dup

        result = yield update
        # Replace the elements here
        @elements = update

        # Most write operations return a reference to self
        # Don't let this reference leak to the caller
        if result.equal? update
          result = self
        end

        return result
      end
    end
  end # ConcurrentList
end
