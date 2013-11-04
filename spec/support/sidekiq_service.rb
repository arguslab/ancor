require 'support/service'

class SidekiqService < Service
  def start
    `bundle exec sidekiq -d -e test -P #{pidfile} -L #{logfile}`
  end

  private

  def logfile
    Rails.root.join('log', 'sidekiq.log')
  end

  def pidfile
    Rails.root.join('tmp', 'pids', 'server.pid')
  end
end
