class EngineHelper
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
          user_data: generate_user_data
        }
      end

      @engine.network_builder = proc do |network|
        network.provider_endpoint = network_endpoint
        network.provider_details = {
          router_id: openstack_config[:router_id]
        }
        network.dns_nameservers = openstack_config[:dns_nameservers]
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
