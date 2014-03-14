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
  # Mixin that provides uniform log access
  #
  # @example
  #   class AwesomeSauceProvider
  #     include Loggable
  #
  #     def provide_the_sauce
  #       logger.debug 'Providing awesome-sauce'
  #     end
  #   end
  module Loggable
    extend ActiveSupport::Concern

    private

    def logger
      Ancor.logger
    end
  end # Loggable
end
