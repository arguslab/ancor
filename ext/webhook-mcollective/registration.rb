module MCollective
  module Agent
    class Registration
      attr_reader :timeout, :meta

      def initialize
        @timeout = 1
        @config = Config.instance
        @meta = {
          :license => "None",
          :author => "Ian Unruh <iunruh@ksu.edu>",
          :url => "https://github.com/ianunruh/ancor"
        }
      end

      def handlemsg(msg, connection)
        reg = msg[:body]

        # TODO send to webhook

        nil
      end

      def help
        %(Registration agent that calls an ANCOR webhook)
      end
    end # Registration
  end # Agent
end
