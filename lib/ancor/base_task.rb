module Ancor
  class BaseTask
    # @return [Hashie::Mash]
    attr_accessor :state

    def initialize
      @state = Hashie::Mash.new
    end

    # @param [Object...] arguments
    # @return [Boolean]
    #   Returns true if the task finished
    #   Returns false if the task will be resumed later
    def perform(*)
      raise NotImplementedError
    end
  end # BaseTask
end
