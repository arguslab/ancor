# This service only runs with Redis installed on OS X
class RedisService
  # Path to the default Redis configuration as packaged with Brew
  CONFIGFILE = '/usr/local/etc/redis.conf'

  # Path to the default Redis pidfile as packaged with Brew
  PIDFILE = '/usr/local/var/run/redis.pid'

  def initialize
    @enabled = RUBY_PLATFORM =~ /darwin/
  end

  def start
    if @enabled
      `redis-server #{CONFIGFILE}`
    end
  end

  def stop
    if @enabled
      pid = File.read PIDFILE
      `kill #{pid}`
    end
  end
end
