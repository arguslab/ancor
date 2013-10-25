require 'puppet'
require 'yaml'

Puppet::Reports.register_report(:ancor_webhook) do

  configfile = File.join([File.dirname(Puppet.settings[:config]), "ancor_webhook.yaml"])
  unless File.exist?(configfile)
    raise Puppet::ParseError, "ANCOR webhook config file #{configfile} not readable"
  end

  config = YAML.load_file(configfile)

  ANCOR_URL = config[:url]

  desc <<-DESC
  Calls a webhook used to notify ANCOR of a Puppet run
  DESC

  def process
    Puppet.debug "Sending status for #{self.host} to ANCOR"
  end

end
