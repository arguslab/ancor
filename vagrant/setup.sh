#!/bin/sh
set -e -x

export DEBIAN_FRONTEND=noninteractive

# Fix dumb issue with $PATH on vagrant box
echo "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" >> /root/.bashrc

apt-get update
apt-get install -y git

git clone git://github.com/arguslab/ancor-environment.git
cd ancor-environment

./install.sh
