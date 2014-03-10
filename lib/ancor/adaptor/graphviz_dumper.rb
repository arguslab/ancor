require 'graphviz'

module Ancor
  module Adaptor
    # Utility for dumping a task graph using GraphViz
    class GraphvizDumper
      # Builds and dumps a task graph, starting with the given tasks
      #
      # @param [String] path
      # @param [Task...] args
      # @return [String] The given path
      def self.dump_to(path, *args)
        dumper = new
        graphviz = dumper.dump(*args)
        graphviz.output(png: path)

        path
      end

      # Dumps a task graph to the operating system's temporary directory
      #
      # @param [Task...] args
      # @return [String] The randomly generated path
      def self.dump_to_tmp(*args)
        filename = SecureRandom.uuid + ".png"
        dump_to(File.join(Dir.tmpdir, filename), *args)
      end

      # @param [Task...] args
      # @return [GraphViz]
      def dump(*args)
        graphviz = GraphViz.new(:G, type: :digraph)
        visited = Set.new

        recursive_dump(graphviz, visited, *args)

        graphviz
      end

      private

      # @param [GraphViz] graphviz
      # @param [Set] visited
      # @param [Task...] tasks
      # @return [undefined]
      def recursive_dump(graphviz, visited, *tasks)
        tasks.each do |task|
          graphviz.add_node(task.id.to_s, label: "#{task.type}\n#{task.id}")

          correlated_tasks(task) do |wh, target|
            graphviz.add_edge(task.id.to_s, target.id.to_s)
            recursive_dump(graphviz, visited, target) if visited.add?(target)
          end
        end
      end

      # @yieldparam [WaitHandle] Wait handle correlated with the given task
      # @yieldparam [Task] Task that will be triggered by the associated wait handle
      # @param [Task] task
      # @return [undefined]
      def correlated_tasks(task)
        WaitHandle.by_correlations(:task_completed, task_id: task.id.to_s).each do |wh|
          wh.tasks.each do |task|
            yield wh, task
          end
        end
      end
    end # GraphvizDumper
  end # Adaptor
end
