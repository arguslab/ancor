require 'ancor'

configfile = Rails.root.join('config', 'ancor.yml')

unless File.exist?(configfile)
  raise "Expected ANCOR configuration file in #{configfile}"
end

Ancor.load_config(configfile)
