require 'spec_helper'

module Ancor
  module Tasks
    describe ProvisionInstance do

      # No instance exists with ec428b08-3b36-11e3-bee0-ce3f5508acd9
      # No instance exists with IP 10.97.226.20
      # Ensure security group ec428b08-3b36-11e3-bee0-ce3f5508acd9 exists
      it 'provisions an instance', live: true do
        options = {
          openstack_api_key: 'user_one',
          openstack_username: 'user_one',
          openstack_auth_url: 'http://192.168.100.51:5000/v2.0/tokens',
          openstack_tenant: 'project_one'
        }

        endpoint = ProviderEndpoint.create(
          type: :os_nova,
          options: options)

        network_details = {
          network_id: '3e0e4ae5-c2a1-48ac-b414-8d586aeb7b13'
        }.stringify_keys

        network = Network.create(provider_details: network_details)

        instance_details = {
          # 'secgroup_id' => '1b2...',
          secgroup_id: '1b248365-29a7-461b-a0c7-2f2febdeb032',
          flavor_id: '1',
          image_id: '4fecad2d-0fa7-43f3-a2a3-91b789bf1883',
          user_data: ''
        }.stringify_keys

        instance = Instance.create(
          name: 'ec428b08-3b36-11e3-bee0-ce3f5508acd9',
          provider_endpoint: endpoint,
          provider_details: instance_details)

        interface = InstanceInterface.create(
          instance: instance,
          network: network,
          ip_address: '10.97.226.20')

        subject.perform(instance.id)
      end

    end
  end
end
