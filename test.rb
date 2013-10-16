

class SecurityGroupService
  ## Contract goes here
end

class OsNeutronSecurityGroupService < SecurityGroupService
  interacts_with :security_groups, :os_neutron

  ## Impl goes here
end

class OsNovaSecurityGroupService < SecurityGroupService
  interacts_with :security_groups, :os_nova

  ## Impl goes here
end


class CreateSecurityGroupTask
  def perform(instance_id)
    instance = Instance.find(instance_id)
    service = Provider.service(instance, :security_groups)

    service.create_group(instance)
  end
end


