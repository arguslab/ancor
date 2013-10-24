require 'spec_helper'

module Ancor
  module Tasks
    describe CreateSecurityGroup do

      # Make sure no security group exists with ec428b08-3b36-11e3-bee0-ce3f5508acd9
      it 'creates a security group for an instance', live: true do
        options = {
          openstack_api_key: 'user_one',
          openstack_username: 'user_one',
          openstack_auth_url: 'http://192.168.100.51:5000/v2.0/tokens',
          openstack_tenant: 'project_one'
        }

        endpoint = ProviderEndpoint.create(
          type: :os_nova,
          options: options)

        instance = Instance.create(
          name: 'ec428b08-3b36-11e3-bee0-ce3f5508acd9',
          provider_endpoint: endpoint)

        subject.perform(instance.id)
      end

    end
  end
end
