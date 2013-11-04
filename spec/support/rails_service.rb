require 'support/service'

class RailsService < Service
  def start
    `#{rails_script} server -d -e test`
  end

  private

  def rails_script
    Rails.root.join('script', 'rails')
  end

  def pidfile
    Rails.root.join('tmp', 'pids', 'server.pid')
  end
end
