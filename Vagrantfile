VAGRANTFILE_API_VERSION = "2"

Vagrant.configure VAGRANTFILE_API_VERSION do |config|
  config.vm.box = "ancor-precise64"
  config.vm.box_url = "https://ianunruh.s3.amazonaws.com/vagrant/ancor-precise64.box"

  config.vm.network :forwarded_port, guest: 61613, host: 61613
  config.vm.network :forwarded_port, guest: 8140, host: 8140
  config.vm.network :forwarded_port, guest: 8080, host: 8000
  config.vm.network :forwarded_port, guest: 3000, host: 3000

  config.vm.provision :shell, path: "vagrant/setup.sh"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on", "--natdnshostresolver1", "on"]
  end
end
