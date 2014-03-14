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
class Channel
  include Mongoid::Document

  field :name, type: String
  field :description, type: String
  field :slug, type: Symbol

  belongs_to :exporter, class_name: "Role", inverse_of: :exports
  has_and_belongs_to_many :importers, class_name: "Role", inverse_of: :imports

  validates :slug, presence: true
  validates :slug, uniqueness: { scope: :exporter_id }
end
