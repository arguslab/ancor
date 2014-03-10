require 'graphviz'

module Ancor
  module Adaptor
    class GraphvizDumper

      def self.dump_and_open(*args)
        graphviz = new.dump(*args)

        path = "/tmp/#{SecureRandom.uuid}.png"
        graphviz.output(png: path)
        system "open #{path}"
      end

      def initialize
        @graphviz = GraphViz.new(:G, type: :digraph)
        @tasks = Set.new
      end

      def dump(*args)
        start = Time.now
        recursive_build_graph(*args)
        elapsed = Time.now - start

        puts "Built task graph in #{elapsed} seconds"

        @graphviz
      end

      private

      def recursive_build_graph(*tasks)
        tasks.each do |task|
          @graphviz.add_node(task.id.to_s, label: task.type)

          each_wait_handle(task.id) do |wh|
            wh.tasks.each do |target|
              @graphviz.add_edge(task.id.to_s, target.id.to_s)
              recursive_build_graph(target) if @tasks.add?(target)
            end
          end
        end
      end

      def each_wait_handle(task_id, &block)
        criteria = {
          type: :task_completed,
          correlations: { task_id: task_id.to_s }.stringify_keys
        }

        WaitHandle.where(criteria).each(&block)
      end
    end # GraphvizDumper
  end # Adaptor
end
