module Ancor
  module Provider
    class PublicIpService < BaseService
      def create(connection, public_ip)
        raise NotImplementedError
      end

      def delete(connection, public_ip)
        raise NotImplementedError
      end

      def associate(connection, public_ip, instance)
        raise NotImplementedError
      end

      def disassociate(connection, public_ip)
        raise NotImplementedError
      end
    end # PublicIpService
  end # Provider
end
