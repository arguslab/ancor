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
