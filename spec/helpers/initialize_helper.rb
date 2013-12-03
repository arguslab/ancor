require 'erb'

module InitializeHelper

  # Pulls in the necessary user data for initializing an instance
  #
  # @param [String] instance_id
  # @return [undefined]
  def inject_user_data(instance_id)
    instance = Instance.find instance_id

    instance.provider_details['user_data'] = generate_user_data
    instance.save
  end

  # Generates user data using the Ubuntu Quantal template and some default
  # values
  #
  # @return [String]
  def generate_user_data
    template = File.read(Rails.root.join('spec', 'config', 'ubuntu-quantal.sh.erb'))

    # Template variables
    hiera_data = File.read(Rails.root.join('spec', 'config', 'defaults.yaml'))
    git_puppet_url = 'git://github.com/ianunruh/ancor-puppet-bootstrap.git'
    git_puppet_branch = 'master'

    ERB.new(template).result(binding)
  end

end
