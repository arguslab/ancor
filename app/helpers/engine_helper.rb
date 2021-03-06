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
module EngineHelper
  def engine
    unless @engine
      network_endpoint = ProviderEndpoint.create(
        type: :os_neutron,
        options: fog_options,
      )

      compute_endpoint = ProviderEndpoint.create(
        type: :os_nova,
        options: fog_options,
      )

      @engine = Ancor::Adaptor::AdaptationEngine.new

      @engine.instance_builder = proc do |instance|
        instance.provider_endpoint = compute_endpoint
        instance.provider_details = {
          flavor_id: openstack_config[:flavor_id],
          image_id: openstack_config[:image_id],
        }
      end

      @engine.network_builder = proc do |network|
        network.provider_endpoint = network_endpoint
        network.provider_details = {
          router_id: openstack_config[:router_id]
        }
        network.dns_nameservers = openstack_config[:dns_nameservers]
      end

      @engine.public_ip_builder = proc do |public_ip|
        public_ip.provider_endpoint = network_endpoint
        public_ip.provider_details = {
          ext_network_id: openstack_config[:ext_network_id]
        }
      end

      @engine.secgroup_builder = proc do |secgroup|
        secgroup.provider_endpoint = network_endpoint

        secgroup.rules = [
          SecurityGroupRule.new(cidr: "0.0.0.0/0", protocol: :tcp, from: 1, to: 65535, direction: :egress),
          SecurityGroupRule.new(cidr: "0.0.0.0/0", protocol: :udp, from: 1, to: 65535, direction: :egress),
          SecurityGroupRule.new(cidr: "0.0.0.0/0", protocol: :tcp, from: 22, to: 22),

          #TODO Remove rules once security groups are updated after add, remove and replace
          SecurityGroupRule.new(cidr: "0.0.0.0/0", protocol: :tcp, from: 1, to: 65535),
          SecurityGroupRule.new(cidr: "0.0.0.0/0", protocol: :udp, from: 1, to: 65535),
        ]

      end
    end

    @engine
  end

  def fog_options
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
