require 'spec_helper'

describe Scenario do
  it 'provides a shortcut to the role it belongs to' do
    role = Role.create
    scenario = Scenario.create role_id: role.id

    scenario.role.should == role
  end
end
