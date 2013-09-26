require 'spec_helper'

require 'fog/openstack/models/network/network'
require 'fog/openstack/models/network/subnet'

describe Ancor::Provisioning::NetworkResource do
  let(:provider) { Object.new }
  let(:document) { Network.create }

  subject { Ancor::Provisioning::NetworkResource.new(document.id) }

  before(:each) do
    Ancor::Provisioning::Provider.network = provider
  end

  it 'does not change the state when it is present and the state to ensure is present' do
    document.status = :present
    document.save

    subject.ensure :present

    document.status.should == :present
  end

  it 'creates the network when it is absent and the state to ensure is present' do
    document.name = SecureRandom.uuid

    document.cidr = '10.128.144.0/24'
    document.ip_version = 4

    router_id = document.provider['router_id'] = SecureRandom.uuid
    dns_nameservers = document.provider['dns_nameservers'] = ['8.8.8.8', '8.8.4.4']

    document.status = :absent
    document.save

    ## First step
    network_options = {
      name: document.name
    }

    os_network = Fog::Network::OpenStack::Network.new network_options
    os_network.id = SecureRandom.uuid

    networks_stub = stub(provider).networks.stub!
    networks_stub.create(network_options) do
      os_network
    end

    # Second step
    subnet_options = {
      network_id: os_network.identity,
      cidr: document.cidr,
      ip_version: document.ip_version,
      dns_nameservers: document.provider['dns_nameservers']
    }

    os_subnet = Fog::Network::OpenStack::Subnet.new subnet_options
    os_subnet.id = SecureRandom.uuid

    subnets_stub = stub(provider).subnets.stub!
    subnets_stub.create(subnet_options) do
      os_subnet
    end

    # Final step
    mock(provider).add_router_interface(router_id, os_subnet.id)

    subject.ensure :present

    document.reload
    # Validate document state as a reflection of the logical network
    document.status.should == :present
    document.provider['network_id'].should == os_network.identity
    document.provider['subnet_id'].should == os_subnet.identity
  end
end
