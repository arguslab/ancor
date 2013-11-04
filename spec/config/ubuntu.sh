#!/bin/sh
###################################################################
# Kickstart script for Ubuntu Precise, Quantal, Raring, Saucy
# Author: Ian Unruh <iunruh@ksu.edu>
###################################################################

## Add user "ksucis"
useradd -m -g sudo -s /bin/bash ksucis
echo ksucis:'K$uci$!' | chpasswd

set -e

MCOLLECTIVE_CONFIG=$(cat <<EOF
topicprefix = /topic/
main_collective = mcollective
collectives = mcollective
libdir = /usr/share/mcollective/plugins
logfile = /var/log/mcollective.log
loglevel = debug
daemonize = 1

# Plugins
securityprovider = psk
plugin.psk = unset

direct_addressing = 1

connector = rabbitmq
plugin.rabbitmq.vhost = /mcollective
plugin.rabbitmq.pool.size = 1
plugin.rabbitmq.pool.1.host = 192.168.100.104
plugin.rabbitmq.pool.1.port = 61613
plugin.rabbitmq.pool.1.user = mcollective
plugin.rabbitmq.pool.1.password = marionette

# Registration
registerinterval = 300
registration = Meta

# Facts
factsource = facter
EOF
)

PATH=/bin:/sbin:/usr/sbin:/usr/bin
KSPATH=/var/tmp/kickstart
LOCKFILE=/var/lock/kickstart

if [ -f "$LOCKFILE" ]; then
    exit 0
fi

touch $LOCKFILE

sed -i 's/nova.clouds.archive.ubuntu.com/mirror.cis.ksu.edu/g' /etc/apt/sources.list

## Install APT repository from Puppet Labs
## Saucy and Raring repositories are still broken, use QUANTAL
wget http://apt.puppetlabs.com/puppetlabs-release-quantal.deb
dpkg -i puppetlabs-release-quantal.deb
apt-get update

## Install both versions of Ruby and switch to 1.8
## MCollective is packaged incorrectly and relies on the wrong version of Ruby
## Puppet doesn't have this issue; they both rely on 1.8, however
apt-get install -y git ruby1.8 rubygems1.8 ruby1.8-dev ruby rubygems ruby-dev ruby-switch ruby-stomp
ruby-switch --set ruby1.8

## Install MCollective and Puppet
apt-get install -y puppet facter mcollective mcollective-facter-facts mcollective-puppet-agent

## Configure MCollective
echo "RUN=yes" > /etc/default/mcollective
echo "$MCOLLECTIVE_CONFIG" > /etc/mcollective/server.cfg

## Clone the plugins repository for MCollective
REPO_PATH=/root/mcollective
PLUGIN_PATH=/usr/share/mcollective/plugins/mcollective

git clone git://github.com/ripienaar/mcollective-server-provisioner.git $REPO_PATH/mcollective-server-provisioner
git clone git://github.com/ripienaar/mcollective-plugins.git $REPO_PATH/mcollective-plugins

cp $REPO_PATH/mcollective-server-provisioner/agent/provision* $PLUGIN_PATH/agent
cp $REPO_PATH/mcollective-plugins/registration/meta* $PLUGIN_PATH/registration

## Cleanup
rm -rf $REPO_PATH

service mcollective restart
