require 'securerandom'
module OpenstackHelper
  @@latest_network_fixture = nil
  @@latest_instance_fixture = nil

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

    if @@latest_network_fixture && Network.where(id: @@latest_network_fixture).exists?
      network_id = @@latest_network_fixture
      network = Network.find network_id
    else
      puts 'Using existing network'

      network_details = {
        network_id: '3e0e4ae5-c2a1-48ac-b414-8d586aeb7b13'
      }.stringify_keys

      network = Network.create(
        cidr:"10.97.226.0/24",
        provider_details: network_details
      )
    end

    

    instance_details = {
      flavor_id: '1',
      image_id: '4fecad2d-0fa7-43f3-a2a3-91b789bf1883',
      user_data: ''
    }.stringify_keys

    instance = Instance.create(
      name: "instance-" + SecureRandom.hex(8),
      provider_endpoint: endpoint,
      provider_details: instance_details)

    #ip_address = "10.97.226.#{rand(25..250)}"
    ip_address = network.cidr.split("0/24")[0] + "#{rand(25..250)}"

    interface = InstanceInterface.create(
      instance: instance,
      network: network,
      ip_address: ip_address)

    @@latest_instance_fixture = instance.id
    instance.id
  end

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
    @@latest_network_fixture = network.id
    network.id

  end
end
