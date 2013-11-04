module InitializeHelper

  # Pulls in the necessary user data for initializing an instance
  #
  # @param [String] instance_id
  # @return [undefined]
  def inject_user_data(instance_id)
    instance = Instance.find instance_id

    user_data = File.read(Rails.root.join('spec', 'config', 'ubuntu.sh'))

    instance.provider_details['user_data'] = user_data
    instance.save
  end

end
