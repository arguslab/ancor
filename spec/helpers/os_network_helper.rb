require 'securerandom'

module OsNetworkHelper
  # @return [String] The network id
  def setup_network_fixture
    options = {
      openstack_api_key: 'user_one',
      openstack_username: 'user_one',
      openstack_auth_url: 'http://192.168.100.51:5000/v2.0/tokens',
      openstack_tenant: 'project_one'
    }

    endpoint = ProviderEndpoint.create(
      type: :os_neutron,
      options: options)

    network_details = {
      router_id: "a4097da1-8851-45fc-9738-26fd9af14f3c"
    }.stringify_keys

    network = Network.create(
      name: 'network-' + SecureRandom.hex(8),
      cidr: "10.#{rand(25..250)}.#{rand(25..250)}.0/24",
      ip_version: 4,
      provider_endpoint: endpoint,
      provider_details: network_details
    )

    network.id

  end
end
