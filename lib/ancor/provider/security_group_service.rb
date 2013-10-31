module Ancor
  module Provider
    class SecurityGroupService < BaseService
      # @param [Object] connection
      # @param [SecurityGroup] secgroup
      # @return [undefined]
      def create(connection, secgroup)
        raise NotImplementedError
      end

      # @param [Object] connection
      # @param [SecurityGroup] secgroup
      # @return [undefined]
      def delete(connection, secgroup)
        raise NotImplementedError
      end

      # @param [Object] connection
      # @param [SecurityGroup] secgroup
      # @return [undefined]
      def update(connection, secgroup)
        raise NotImplementedError
      end
    end # SecurityGroupService
  end # Provider
end
