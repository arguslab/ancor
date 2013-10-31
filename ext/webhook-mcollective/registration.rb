require 'uri'
require 'net/http'

module MCollective
  module Agent
    class Registration
      attr_reader :timeout, :meta

      def initialize
        @timeout = 10
        @config = Config.instance
        @meta = {
          :license => "None",
          :author => "Ian Unruh <iunruh@ksu.edu>",
          :url => "https://github.com/ianunruh/ancor"
        }
      end

      def handlemsg(msg, connection)
        req = msg[:body]

        endpoint = @config.pluginconf["registration.endpoint"]

        uri = URI.parse endpoint

        http = Net::HTTP.new uri.host, uri.port
        # TODO Fix SSL support
        # http.use_ssl = uri.scheme == "https"

        http.post(uri.path, YAML.dump(req))

        nil
      end

      def help
        %(Simple registration agent that calls a webhook every time the sender checks in)
      end
    end # Registration
  end # Agent
end
