module Ancor
  module Provider
    class InstanceService

      def create_instance(connection,instance)
        raise NotImplementedError
      end

      def terminate_instance(connection,instance)
        raise NotImplementedError
      end	

    end # InstanceService
  end 
end