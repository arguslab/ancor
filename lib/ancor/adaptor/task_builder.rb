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
module Ancor
  module Adaptor
    # @abstract
    class TaskBuilder
      include AbstractType

      # @yield
      # @return [TaskBuilder]
      def self.build(&block)
        new.tap do |builder|
          builder.build(&block)
        end
      end

      # @return [Enumerable]
      abstract_method :heads

      # @return [Task]
      abstract_method :tail

      # @return [Boolean]
      abstract_method :empty?

      # @yield
      # @return [undefined]
      def build(&block)
        instance_exec(&block)
      end

      # @param [Class] type
      # @param [Object...] args
      # @return [Task]
      def create_task(type, *args)
        Task.create(type: type.name, arguments: args)
      end
    end # TaskBuilder
  end # Adaptor
end

require 'ancor/adaptor/task_builder/chain'
require 'ancor/adaptor/task_builder/parallel'
