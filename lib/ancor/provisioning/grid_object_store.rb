module Ancor
  module Provisioning
    class GridObjectStore < ObjectStore
      def get(id)
        Mongoid::GridFs.get(id).data
      end
    end # GridObjectStore
  end # Provisioning
end
