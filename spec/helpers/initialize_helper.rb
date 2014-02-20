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
    config = Ancor.config
    template = File.read(Rails.root.join('spec', 'config', 'ubuntu-precise.sh.erb'))

    ERB.new(template).result(binding)
  end

end
