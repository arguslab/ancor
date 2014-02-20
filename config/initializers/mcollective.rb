conf_path = Rails.root.join('config', 'mcollective.cfg')
vendor_path = Rails.root.join('vendor', 'marionette-collective')

unless Dir.exist?(vendor_path)
  raise 'Portable MCollective has not been installed. Run `bin/setup-mcollective` and try again.'
end

require 'mcollective'

config = MCollective::Config.instance
unless config.configured
  config.loadconfig conf_path
end
