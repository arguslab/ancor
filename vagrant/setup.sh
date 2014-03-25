#!/bin/sh
export DEBIAN_FRONTEND=noninteractive

# Fix weird issue with $PATH on vagrant box
echo "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" >> /root/.bashrc

apt-get update
apt-get install -y git

git clone git://github.com/arguslab/ancor-environment.git
cd ancor-environment

./install.sh

su -c "cd /vagrant && vagrant/setup-local.sh" vagrant
