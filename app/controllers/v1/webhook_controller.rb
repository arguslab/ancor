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
    def puppet
      report = YAML.load(request.body)

      instance_name, _ = report.host.split('.')
      instance = Instance.find_by(name: instance_name)

      model = instance.puppet_reports.create!(
        transaction_uuid: report.transaction_uuid,
        started_at: report.time,
        status: report.status,
      )

      if model.success?
        process_wait_handles(:run_completed, instance)
      else
        process_wait_handles(:run_failed, instance)
      end

      render nothing: true, status: 200
    end

    private

    def process_wait_handles(type, instance)
      WaitHandle.each_task(type, instance_id: instance.id) do |id|
        Ancor::TaskWorker.perform_async(id)
      end
    end
  end # WebhookController
end # V1
