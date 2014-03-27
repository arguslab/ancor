#!/bin/bash
curl -s -L https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm

rvm install ruby-1.9.3
rvm use --default ruby-1.9.3
ruby -v

gem install bundler
gem install ancor-cli
cd /vagrant && bundle install
