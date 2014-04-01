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
class Instance
  include Mongoid::Document
  include Lockable
  include Providable
  include Ancor::Extensions::IndifferentAccess

  STAGES = [
    :setup,
    :configure,
    :deploy,
    :undeploy,
  ]

  SPECIAL_STAGES = [
    :error,
    :undefined,
  ]

  field :name, type: String

  field :stage, type: Symbol, default: :undefined
  field :planned_stage, type: Symbol, default: :undefined

  belongs_to :role
  belongs_to :scenario

  has_one :public_ip, dependent: :nullify

  has_many :interfaces, class_name: "InstanceInterface"

  has_and_belongs_to_many :security_groups

  embeds_many :channel_selections

  field :cmt_details, type: Hash, default: -> { {} }, pre_processed: true

  has_many :puppet_reports, dependent: :destroy

  validates :name, presence: true

  def environment
    role.environment
  end

  def networks
    interfaces.map { |interface|
      interface.network
    }
  end

  def public?
    role.public?
  end
end
