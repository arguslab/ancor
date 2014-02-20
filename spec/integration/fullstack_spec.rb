require 'spec_helper'

describe 'Integration suite for full application stack' do
  include InitializeHelper
  include OpenStackHelper
  include Ancor::Operational

  it 'deploys all roles using the adaptor', integration: true do
    build_model

    network_endpoint = ProviderEndpoint.create(
      type: :os_neutron,
      options: openstack_options,
    )

    compute_endpoint = ProviderEndpoint.create(
      type: :os_nova,
      options: openstack_options,
    )

    engine = Ancor::Adaptor::AdaptationEngine.new

    engine.instance_builder = proc do |instance|
      instance.provider_endpoint = compute_endpoint
      instance.provider_details = {
        flavor_id: openstack_config[:flavor_id],
        image_id: openstack_config[:image_id],
        user_data: generate_user_data
      }
    end

    engine.network_builder = proc do |network|
      network.provider_endpoint = network_endpoint
      network.provider_details = {
        router_id: openstack_config[:router_id]
      }
      network.dns_nameservers = openstack_config[:dns_nameservers]
    end

    engine.plan

    puts 'Press CTRL+D to launch'
    binding.pry

    engine.launch

    puts 'Press CTRL+D when finished'
    binding.pry
  end

  private

  def build_model
    yb = Ancor::Adaptor::YamlBuilder.new
    yb.build_from(Rails.root.join(*%w(spec fixtures arml fullstack.yaml)))
    yb.commit
  end
end
