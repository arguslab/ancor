module Ancor
  module Tasks
    class EnsureResourceState
      def perform(type, id, state)
        type.constantize.new(id).ensure(state)
      end
    end # EnsureResourceState
  end # Tasks
end
