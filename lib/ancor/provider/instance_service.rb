module Ancor
  module Provider
    class InstanceService < BaseService
      # @param [Object] connection
      # @param [Instance] instance
      # @return [Boolean]
      def active?(connection, instance)
        raise NotImplementedError
      end

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
      # @return [Boolean]
      def error?(connection, instance)
        raise NotImplementedError
      end

      # @param [Object] connection
      # @param [Instance] instance
      # @return [Boolean]
      def exists?(connection, instance)
        raise NotImplementedError
      end
    end # InstanceService
  end # Provider
end
