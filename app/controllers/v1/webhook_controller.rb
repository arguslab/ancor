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
module V1
  class WebhookController < ApplicationController
    def mcollective
      body = request.body.read
      meta = YAML.load body

      host = meta[:identity].split('.')[0]
      instance = Instance.where(name: host).first

      if instance
        process_wait_handles :instance_registered, instance.id
      else
        # TODO Log missing instances
      end

      render nothing: true, status: 200
    end

    def puppet
      body = request.body.read
      transaction = YAML.load body

      # Don't care about the domain name (for now)
      host = transaction.host.split('.')[0]
      instance = Instance.where(name: host).first

      if instance
        if transaction.status == 'failed'
          process_wait_handles :run_failed, instance.id
        else
          process_wait_handles :run_completed, instance.id
        end
      else
        # TODO Log missing instances
      end

      render nothing: true, status: 200
    end

    private

    def process_wait_handles(type, instance_id)
      WaitHandle.each_task(type, instance_id: instance_id) do |id|
        Ancor::TaskWorker.perform_async id
      end
    end
  end # WebhookController
end # V1
