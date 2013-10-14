module Ancor
  class BaseTask
    # @return [Task]
    attr_accessor :context

    def store
      @context.store
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
