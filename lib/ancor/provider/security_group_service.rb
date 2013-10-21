module Ancor
  module Provider
    class SecurityGroupService < BaseService
      # @param [Object] connection
      # @param [Instance] instance
      # @return [undefined]
      def create(connection, instance)
        raise NotImplementedError
      end

      # @param [Object] connection
      # @param [Instance] instance
      # @return [undefined]
      def delete(connection, instance)
        raise NotImplementedError
      end

      # @param [Object] connection
      # @param [Instance] instance
      # @return [undefined]
      def update(connection, instance)
        raise NotImplementedError
      end
    end # SecurityGroupService
  end # Provider
end
