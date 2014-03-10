module Ancor
  module Adaptor
    class ParallelTaskBuilder < TaskBuilder
      attr_reader :heads
      attr_reader :tail

      def initialize
        @heads = Array.new
        @tail_ids = Array.new
        @tail = create_task(Tasks::Sink, @tail_ids)
      end

      def empty?
        @heads.empty?
      end

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

      def parallel(&block)
        instance_exec(&block)
      end

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
