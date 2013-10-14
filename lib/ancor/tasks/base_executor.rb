module Ancor
  module Tasks
    class BaseExecutor
      # @return [Task]
      attr_accessor :context

      def store
        @context.store
      end

      # @param [Object...] arguments
      # @return [Boolean]
      #   Returns true if the executor finished
      #   Returns false if the executor will be resumed later
      def perform(*)
        raise NotImplementedError
      end
    end # BaseExecutor
  end
end
