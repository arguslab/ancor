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
