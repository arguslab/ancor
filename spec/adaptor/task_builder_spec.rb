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
  module Adaptor

    ExampleTask = Class.new

    describe ChainTaskBuilder do
      after(:each) do
        puts "Task graph generated, available at:", GraphvizDumper.dump_to_tmp(*subject.heads)
      end

      it 'structures tasks in a chain' do
        subject.build do
          task ExampleTask, 1
          task ExampleTask, 2
          task ExampleTask, 3
        end
      end

      it 'structures tasks in a chain with parallel tasks' do
        subject.build do
          parallel do
            task ExampleTask
            task ExampleTask
          end

          task ExampleTask
          task ExampleTask

          parallel do
            chain do
              parallel do
                task ExampleTask
                task ExampleTask
              end
              task ExampleTask
            end
            chain do
              task ExampleTask
              task ExampleTask
            end
          end

          task ExampleTask
        end
      end
    end

  end
end
