require 'spec_helper'

module Ancor
  module Provider

    TestInstanceService = Class.new InstanceService

    describe ServiceLocator do
      subject { ServiceLocator.instance }

      it 'creates connections using connection factories' do
        ep = ProviderEndpoint.new
        ep.type = :os_something
        ep.options = { :foo => 0 }

        connection = Object.new

        subject.register_connection_factory(ep.type) { |options|
          options.should eql(ep.options)
          connection
        }

        subject.connection(ep).should be(connection)
      end

      it 'caches services' do
        subject.register_service :os_test, TestInstanceService

        service_a = subject.service(:os_test, InstanceService)
        service_b = subject.service(:os_test, InstanceService)

        service_a.should be_a(TestInstanceService)
        service_b.should be(service_a)
      end

      it 'raises an exception if no service could be found' do
        expect {
          subject.service(:os_somethingelse, InstanceService)
        }.to raise_error(ServiceNotFoundError)
      end
    end

  end
end
