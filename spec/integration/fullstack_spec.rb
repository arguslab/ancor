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
        flavor_id: '1',
        image_id: '4fecad2d-0fa7-43f3-a2a3-91b789bf1883',
        user_data: generate_user_data
      }
    end

    engine.network_builder = proc do |network|
      network.provider_endpoint = network_endpoint
      network.provider_details = {
        router_id: 'a4097da1-8851-45fc-9738-26fd9af14f3c'
      }
      network.dns_nameservers = ['8.8.8.8', '8.8.4.4']
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
