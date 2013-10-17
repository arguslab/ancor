module Ancor
  module Provider
    class NetworkService < BaseService
      
      def create_network(connection,instance)
        raise NotImplementedError
      end

      def terminate_network(connection,instance)
        raise NotImplementedError
      end 
    end # NetworkService
  end 
end