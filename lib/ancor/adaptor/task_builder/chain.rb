module Ancor
  module Adaptor
    class ChainTaskBuilder < TaskBuilder
      attr_reader :heads
      attr_reader :tail

      def empty?
        @heads.nil? || @heads.empty?
      end

      def task(type, *args)
        task = create_task(type, *args)
        insert_task(task)
        @tail = task
      end

      def chain(&block)
        instance_exec(&block)
      end

      def parallel(&block)
        builder = ParallelTaskBuilder.build(&block)

        unless builder.empty?
          insert_task(*builder.heads)
          @tail = builder.tail
        end
      end

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
