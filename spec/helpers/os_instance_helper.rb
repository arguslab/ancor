require 'securerandom'
module OsInstanceHelper

  # @return [String] The instance id
  def setup_instance_fixture
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
      flavor_id: '1',
      image_id: '4fecad2d-0fa7-43f3-a2a3-91b789bf1883',
      user_data: ''
    }.stringify_keys

    instance = Instance.create(
      name: "instance-" + SecureRandom.hex(8),
      provider_endpoint: endpoint,
      provider_details: instance_details)

    ip_address = "10.97.226.#{rand(25..250)}"

    interface = InstanceInterface.create(
      instance: instance,
      network: network,
      ip_address: ip_address)

    instance.id
  end
end
