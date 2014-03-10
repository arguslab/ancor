module Ancor
  module Adaptor
    # Serializes multiple tasks into a single chain
    #
    # @example Two tasks in a chain
    #   chain do
    #     task ExampleTask
    #     task ExampleTask
    #   end
    #
    # @example Two sets of parallel tasks in a chain
    #   chain do
    #     parallel do
    #       task ExampleTask
    #       task ExampleTask
    #     end
    #
    #     parallel do
    #       task ExampleTask
    #       task ExampleTask
    #     end
    #   end
    class ChainTaskBuilder < TaskBuilder
      # @return [Enumerable]
      attr_reader :heads

      # @return [Enumerable]
      attr_reader :tail

      # @return [Boolean]
      def empty?
        @heads.nil? || @heads.empty?
      end

      # @param [Class] type
      # @param [Object...] args
      # @return [undefined]
      def task(type, *args)
        task = create_task(type, *args)
        insert_task(task)
        @tail = task
      end

      # @yield
      # @return [undefined]
      def chain(&block)
        instance_exec(&block)
      end

      # @yield
      # @return [undefined]
      def parallel(&block)
        builder = ParallelTaskBuilder.build(&block)

        unless builder.empty?
          insert_task(*builder.heads)
          @tail = builder.tail
        end
      end

      private

      # @param [Task...] args
      # @return [undefined]
      def insert_task(*args)
        if @heads
          @tail.trigger(*args)
        else
          @heads = args
        end
      end
    end # ChainTaskBuilder
  end # Adaptor
end
