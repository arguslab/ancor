module Ancor
  module Adaptor
    # Parallelizes multiple tasks into a single task sink
    #
    # @example Two tasks in parallel
    #   parallel do
    #     task ExampleTask
    #     task ExampleTask
    #   end
    #
    # @example Two chains of tasks in parallel
    #   parallel do
    #     chain do
    #       task ExampleTask
    #       task ExampleTask
    #     end
    #
    #     chain do
    #       task ExampleTask
    #       task ExampleTask
    #     end
    #   end
    class ParallelTaskBuilder < TaskBuilder
      # @return [Enumerable]
      attr_reader :heads

      # @return [Task]
      attr_reader :tail

      # @return [undefined]
      def initialize
        @heads = Array.new
        @tail_ids = Array.new
        @tail = create_task(Tasks::Sink, @tail_ids)
      end

      # @return [Boolean]
      def empty?
        @heads.empty?
      end

      # @yield
      # @return [undefined]
      def chain(&block)
        builder = ChainTaskBuilder.build(&block)

        unless builder.empty?
          heads = builder.heads
          tail = builder.tail

          @heads.push(*heads)
          @tail_ids.push(tail.id)
          tail.trigger(@tail)

          @tail.save
        end
      end

      # @yield
      # @return [undefined]
      def parallel(&block)
        instance_exec(&block)
      end

      # @param [Class] type
      # @param [Object...] args
      # @return [undefined]
      def task(type, *args)
        task = create_task(type, *args)

        @heads.push(task)
        @tail_ids.push(task.id)
        task.trigger(@tail)

        @tail.save
      end
    end # ParallelTaskBuilder
  end # Adaptor
end
