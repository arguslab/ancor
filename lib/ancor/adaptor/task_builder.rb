module Ancor
  module Adaptor
    # @abstract
    class TaskBuilder
      include AbstractType

      # @yield
      # @return [TaskBuilder]
      def self.build(&block)
        new.tap do |builder|
          builder.build(&block)
        end
      end

      # @return [Enumerable]
      abstract_method :heads

      # @return [Task]
      abstract_method :tail

      # @return [Boolean]
      abstract_method :empty?

      # @yield
      # @return [undefined]
      def build(&block)
        instance_exec(&block)
      end

      # @param [Class] type
      # @param [Object...] args
      # @return [Task]
      def create_task(type, *args)
        Task.create(type: type.name, arguments: args)
      end
    end # TaskBuilder
  end # Adaptor
end

require 'ancor/adaptor/task_builder/chain'
require 'ancor/adaptor/task_builder/parallel'
