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
class WaitHandle
  include Mongoid::Document

  field :type, type: Symbol
  field :correlations, type: Hash, default: -> { {} }

  has_and_belongs_to_many :tasks

  before_save do
    self.correlations = self.class.normalize_hash correlations
  end

  def self.correlated_tasks(type, correlations = {})
    by_correlations(type, correlations).pluck(:task_ids).flatten.uniq.map(&:to_s)
  end

  def self.by_correlations(type, correlations = {})
    criteria = {
      type: type,
      correlations: normalize_hash(correlations)
    }

    where(criteria)
  end

  def self.each_task(type, correlations = {}, &block)
    correlated_tasks(type, correlations).each(&block)
  end

  private

  # Coerces all keys and values in the given hash to strings
  #
  # @param [Hash] h
  # @return [Hash]
  def self.normalize_hash(h)
    Hash[h.map { |k, v| [k.to_s, v.to_s] }]
  end
end
