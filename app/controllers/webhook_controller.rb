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
end
