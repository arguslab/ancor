class Service
  def start
    raise NotImplementedError
  end

  def stop
    pid = File.read pidfile
    `kill #{pid}`
  end

  private

  def pidfile
    raise NotImplementedError
  end
end
