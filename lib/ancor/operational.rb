module Ancor
  module Operational
    TimeoutError = Class.new RuntimeError

    def attempt(max_attempts = 5, interval = 1)
      i = 0

      loop do
        i += 1

        begin
          return yield
        rescue
          raise if i == max_attempts
        end

        sleep interval
      end
    end

    def wait_while(timeout = 30, interval = 1)
      start = Time.now
      while yield
        elapsed = Time.now - start

        if elapsed.to_i > timeout
          raise TimeoutError
        end

        sleep interval
      end
    end

    def wait_until(timeout = 30, interval = 1)
      start = Time.now
      until yield
        elapsed = Time.now - start

        if elapsed.to_i > timeout
          raise TimeoutError
        end

        sleep interval
      end
    end
  end # Operational
end
