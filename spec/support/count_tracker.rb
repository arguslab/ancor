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
# Used to track the change in count for model objects
#
# Note that this can only be used with objects or classes that have a
# consistent hash
class CountTracker
  # @param [Object...] sources
  # @return [undefined]
  def initialize(*sources)
    @sources = {}
    sources.each { |s| @sources[s] = s.count }
  end

  # @param [Object] source
  # @param [Integer] expectation
  # @return [Boolean]
  def has_change?(source, expectation)
    change(source) == expectation
  end

  # @param [Object] source
  # @return [Integer]
  def change(source)
    source.count - @sources.fetch(source)
  end

  def changes
    @sources.map { |source, count|
      source.count - count
    }
  end
end
