require 'mcollective'

config = MCollective::Config.instance
unless config.configured
  conf_path = Rails.root.join('config', 'mcollective', 'client.conf')
  lib_path = Rails.root.join('lib')

  unless Dir.exist?(File.join(lib_path, 'mcollective'))
    raise 'Portable MCollective has not been installed. Run `bin/setup-mcollective` and try again.'
  end

  config.loadconfig conf_path
  # getting pretty tired of your shit, mcollective
  # https://github.com/puppetlabs/marionette-collective/blob/2.4.x/lib/mcollective/config.rb#L128
  # config.libdir << lib_path
end
