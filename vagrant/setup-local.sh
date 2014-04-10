#!/bin/bash
RUBY_VERSION=ruby-2.1

curl -s -L https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm

rvm install $RUBY_VERSION
rvm use --default $RUBY_VERSION
ruby -v

gem install bundler
gem install ancor-cli
cd /vagrant && bundle install
