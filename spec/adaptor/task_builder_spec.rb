require 'spec_helper'

module Ancor
  module Adaptor

    ExampleTask = Class.new

    describe ChainTaskBuilder do
      after(:each) do
        puts "Task graph generated, available at:", GraphvizDumper.dump_to_tmp(*subject.heads)
      end

      it 'structures tasks in a chain' do
        subject.build do
          task ExampleTask, 1
          task ExampleTask, 2
          task ExampleTask, 3
        end
      end

      it 'structures tasks in a chain with parallel tasks' do
        subject.build do
          parallel do
            task ExampleTask
            task ExampleTask
          end

          task ExampleTask
          task ExampleTask

          parallel do
            chain do
              parallel do
                task ExampleTask
                task ExampleTask
              end
              task ExampleTask
            end
            chain do
              task ExampleTask
              task ExampleTask
            end
          end

          task ExampleTask
        end
      end
    end

  end
end
