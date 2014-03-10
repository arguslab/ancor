module Ancor
  module Adaptor
    class TaskBuilder
      include AbstractType

      def self.build(&block)
        new.tap do |builder|
          builder.build(&block)
        end
      end

      def build(&block)
        instance_exec(&block)
      end

      def create_task(type, *args)
        Task.create(type: type.name, arguments: args)
      end
    end # TaskBuilder
  end # Adaptor
end

require 'ancor/adaptor/task_builder/chain'
require 'ancor/adaptor/task_builder/parallel'
