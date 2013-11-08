require 'spec_helper'

describe Role do
  let(:dependent_a) { Role.create }
  let(:dependent_b) { Role.create }

  before do
    channel_a = Channel.create(exporter: subject, importers: [dependent_a])
    channel_b = Channel.create(exporter: subject, importers: [dependent_a, dependent_b])
  end

  it 'collects dependent roles' do
    subject.dependent_roles.should == [dependent_a, dependent_b]
  end

  it 'collects dependent instances' do
    instance_a = Instance.create(role: dependent_a)
    instance_b = Instance.create(role: dependent_b)
    instance_c = Instance.create(role: dependent_b)

    subject.dependent_instances.should == [instance_a, instance_b, instance_c]
  end
end
