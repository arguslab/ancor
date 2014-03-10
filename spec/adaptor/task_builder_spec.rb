require 'spec_helper'

module Ancor
  module Adaptor

    ExampleTask = Class.new

    describe ChainTaskBuilder do
      it 'structures tasks in a chain' do

        subject.build do
          task ExampleTask, 1
          task ExampleTask, 2
          task ExampleTask, 3
        end

      end

      it 'structures tasks in a chain with parallel tasks' do

        subject.build do
          task ExampleTask, 1

          parallel do
            task ExampleTask, 2
            task ExampleTask, 3
          end

          parallel do
            task ExampleTask, 5
          end

          task ExampleTask, 4
        end

      end
    end

  end
end
