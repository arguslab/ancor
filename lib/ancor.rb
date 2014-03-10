begin
  require 'mcollective'
rescue LoadError
  raise 'MCollective not available, make sure you run `bin/setup-mcollective`'
end

require 'fog'
require 'hashie'
require 'puppet'
require 'thread_safe'
require 'yaml'

require 'ancor/concurrent_list'
require 'ancor/loggable'
require 'ancor/operational'

require 'ancor/extensions/indifferent_access'

module Ancor
  extend self

  # @return [Hash]
  attr_accessor :config

  # @return [Logger]
  attr_accessor :logger

  def load_config(path)
    @config = YAML.load(File.read(path)).with_indifferent_access
  end

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

require 'ancor/adaptor/adaptation_engine'
require 'ancor/adaptor/import_selector'
require 'ancor/adaptor/task_builder'
require 'ancor/adaptor/yaml_builder'
require 'ancor/adaptor/graphviz_dumper'

require 'ancor/conductor/client_lock'
require 'ancor/conductor/client_util'

require 'ancor/provider/service_locator'
require 'ancor/provider/base_service'
require 'ancor/provider/instance_service'
require 'ancor/provider/network_service'
require 'ancor/provider/public_ip_service'
require 'ancor/provider/security_group_service'
require 'ancor/provider/openstack'

require 'ancor/tasks/base_executor'
require 'ancor/tasks/sink'

require 'ancor/tasks/clean_puppet_certificate'
require 'ancor/tasks/unlock_environment'
require 'ancor/tasks/deploy_instance'
require 'ancor/tasks/delete_instance'
require 'ancor/tasks/provision_instance'
require 'ancor/tasks/push_configuration'

require 'ancor/tasks/delete_network'
require 'ancor/tasks/provision_network'

require 'ancor/tasks/allocate_public_ip'
require 'ancor/tasks/deallocate_public_ip'
require 'ancor/tasks/associate_public_ip'
require 'ancor/tasks/disassociate_public_ip'

require 'ancor/tasks/delete_security_group'
require 'ancor/tasks/sync_security_group'
