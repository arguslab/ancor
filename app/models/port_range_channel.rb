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
class PortRangeChannel < Channel
  field :protocol, type: Symbol
  field :size, type: Integer

  field :number, type: Integer

  validates :protocol, presence: true
	validates :size,  presence: true, numericality: { 
																			only_integer: true, 
																			greater_than_or_equal_to: 0, 
																			less_than: 65536 }

  validates :number, numericality: { only_integer: true, greater_than: 0, less_than: 65536 },
  	if: :within_range

  def within_range
  	errors.add(:within_range, "(port number + size) should be less or equal to 65535") unless number? and (number + size) <= 65535
  end
end #PortRangeChannel
