module Ancor
  module Provider
    class NetworkService < BaseService
      # @param [Object] connection
      # @param [Network] network
      # @return [undefined]
      def create(connection, network)
        raise NotImplementedError
      end

      # @param [Object] connection
      # @param [Network] network
      # @return [undefined]
      def delete(connection, network)
        raise NotImplementedError
      end
    end # NetworkService
  end # Provider
end
