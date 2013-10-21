module Ancor
  module Provider
    class OpenStackInstanceService < InstanceService
      interacts_with :os_nova

      # @param [Fog::Compute::OpenStack] connection
      # @param [Instance] instance
      # @return [undefined]
      def create(connection, instance)
        # TODO Lock the instance for this operation

        options = {
          name: instance.name,
          flavor_ref: instance.provider_details["flavor_id"],
          image_ref: instance.provider_details["image_id"],
          nics: instance.networks,
          # security_groups: [security_group],
          user_data: instance.provider_details["user_data"] #@obj_store
        }
        os_instance = connection.servers.create options
      end

      # @param [Fog::Compute::OpenStack] connection
      # @param [Instance] instance
      # @return [undefined]
      def delete(connection, instance)
        # TODO Lock the instance for this operation

        os_instance = connection.servers.find do |i|
          i.name == instance.name
        end

        os_instance.destroy
      end
    end # OpenStackInstanceService
  end # Provider
end
