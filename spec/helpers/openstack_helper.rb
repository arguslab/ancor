# Author: Ian Unruh, Alexandru G. Bardas
# Copyright (C) 2013-2014 Argus Cybersecurity Lab, Kansas State University
#
# This file is part of ANCOR.
#
# ANCOR is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ANCOR is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with ANCOR.  If not, see <http://www.gnu.org/licenses/>.
require 'securerandom'

module OpenStackHelper
  # @return [String] The security group id
  def setup_secgroup_fixture
    endpoint = ProviderEndpoint.create(
      type: :os_neutron,
      options: openstack_options)

    cidr = '0.0.0.0/0'

    secgroup = SecurityGroup.new(provider_endpoint: endpoint)
    secgroup.rules << SecurityGroupRule.new(protocol: :tcp, from: 22, to: 22, cidr: cidr)
    secgroup.rules << SecurityGroupRule.new(protocol: :udp, from: 3306, to: 3306, cidr: cidr)
    secgroup.rules << SecurityGroupRule.new(protocol: :tcp, from: 50, to: 50, cidr: cidr)
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
      flavor_id: openstack_config[:flavor_id],
      image_id: openstack_config[:image_id],
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
      router_id: openstack_config[:router_id]
    }

    network = Network.create(
      name: 'network-' + SecureRandom.hex(8),
      cidr: "10.#{rand(25..250)}.#{rand(25..250)}.0/24",
      ip_version: 4,
      dns_nameservers: openstack_config[:dns_nameservers],
      provider_endpoint: endpoint,
      provider_details: network_details
    )

    network.id
  end

  private

  def openstack_options
    {
      openstack_api_key: openstack_config[:api_key],
      openstack_username: openstack_config[:username],
      openstack_auth_url: openstack_config[:auth_url],
      openstack_tenant: openstack_config[:tenant]
    }
  end

  def openstack_config
    @openstack_config ||= Ancor.config[:openstack]
  end
end
