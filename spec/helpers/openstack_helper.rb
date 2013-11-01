require 'securerandom'

module OpenStackHelper
  # @return [String] The security group id
  def setup_secgroup_fixture
    endpoint = ProviderEndpoint.create(
      type: :os_nova,
      options: openstack_options)

    cidr = '0.0.0.0/0'

    secgroup = SecurityGroup.new(provider_endpoint: endpoint)
    secgroup.rules << SecurityGroupRule.new(protocol: :tcp, from: 1, to: 65535, cidr: cidr)
    secgroup.rules << SecurityGroupRule.new(protocol: :udp, from: 1, to: 65535, cidr: cidr)
    secgroup.rules << SecurityGroupRule.new(protocol: :icmp, from: -1, to: -1, cidr: cidr)
    secgroup.save

    secgroup.id
  end

  # @param [String] network_id
  # @param [String] secgroup_id
  # @return [String] The instance id
  def setup_instance_fixture(network_id = nil, secgroup_id = nil)
    endpoint = ProviderEndpoint.create(
      type: :os_nova,
      options: openstack_options)

    instance_details = {
      flavor_id: '1',
      image_id: '4fecad2d-0fa7-43f3-a2a3-91b789bf1883',
      user_data: '',
    }

    instance = Instance.create(
      name: 'instance-' + SecureRandom.hex(8),
      provider_endpoint: endpoint,
      provider_details: instance_details)

    if network_id
      network = Network.find network_id

      ip_address = network.cidr.split('0/24')[0] + rand(20..250).to_s

      interface = InstanceInterface.create(
        instance: instance,
        network: network,
        ip_address: ip_address)
    end

    if secgroup_id
      secgroup = SecurityGroup.find secgroup_id
      instance.security_groups << secgroup
    end

    instance.id
  end

  # @return [String] The network id
  def setup_network_fixture
    endpoint = ProviderEndpoint.create(
      type: :os_neutron,
      options: openstack_options)

    network_details = {
      router_id: 'a4097da1-8851-45fc-9738-26fd9af14f3c'
    }

    network = Network.create(
      name: 'network-' + SecureRandom.hex(8),
      cidr: "10.#{rand(25..250)}.#{rand(25..250)}.0/24",
      ip_version: 4,
      dns_nameservers: ['8.8.8.8', '8.8.4.4'],
      provider_endpoint: endpoint,
      provider_details: network_details
    )

    network.id
  end

  private

  def openstack_options
    {
      openstack_api_key: 'user_one',
      openstack_username: 'user_one',
      openstack_auth_url: 'http://192.168.100.51:5000/v2.0/tokens',
      openstack_tenant: 'project_one'
    }
  end
end
