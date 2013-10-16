module Ancor
  module Provider
    class SecurityGroupService

      def create_security_group(connection,instance)
        raise NotImplementedError
      end

      def delete_security_group(connection,instance)
        raise NotImplementedError
      end

      def update_security_group(connection,instance)
        raise NotImplementedError
      end
    end # SecurityGroupService
  end 
end