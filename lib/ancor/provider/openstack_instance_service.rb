require 'fog'

module Ancor
  module Provider
    class OpenStackInstanceService < InstanceService 

      def create_instance(connection,instance)
        options = {
          name: instance.name,
          flavor_ref: instance.provider_details["flavor_id"],
          image_ref: instance.provider_details["image_id"],
          nics: nics,
          # security_groups: [security_group],
          user_data: user_data
        }
        os_instance = connection.servers.create options
      end

      def terminate_instance(connection,instance)
        os_instance = connection.servers.find do |i|
          i.name == instance.name
        end
        os_instance.destroy
      end

    end # OpenStackInstanceService
  end 
end