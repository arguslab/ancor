require 'fog'
require 'hashie'
require 'mcollective'
require 'puppet'
require 'thread_safe'
require 'ancor/concurrent_list'

require 'ancor/loggable'
require 'ancor/operational'

require 'ancor/extensions/indifferent_access'

module Ancor
  extend self

  # @return [Logger]
  attr_accessor :logger

  def setup_logger
    @logger = Logger.new $stdout
    @logger.datetime_format = '%Y-%m-%d %I:%M%P'
    @logger.formatter = proc do |severity, datetime, progname, msg|
      "[#{severity}] [#{datetime}]: #{msg}\n"
    end
  end
end

Ancor.setup_logger

require 'ancor/errors'

require 'ancor/adaptor/import_selector'
require 'ancor/adaptor/yaml_builder'

require 'ancor/conductor/client_lock'
require 'ancor/conductor/client_util'

require 'ancor/provider/service_locator'
require 'ancor/provider/base_service'
require 'ancor/provider/instance_service'
require 'ancor/provider/network_service'
require 'ancor/provider/security_group_service'
require 'ancor/provider/openstack'

require 'ancor/tasks/base_executor'
require 'ancor/tasks/delete_instance'
require 'ancor/tasks/delete_network'
require 'ancor/tasks/delete_security_group'
require 'ancor/tasks/deploy_instance'
require 'ancor/tasks/initialize_instance'
require 'ancor/tasks/provision_instance'
require 'ancor/tasks/push_configuration'
require 'ancor/tasks/sync_security_group'

