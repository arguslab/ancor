## What is ANCOR?

ANCOR is a cloud automation framework that models dependencies between different layers in an
application stack. When instances in one layer changes, the instances in a dependent layer
are notified and reconfigured.

Think of it like OpsWorks with dependency management.

## Developing ANCOR

### Ubuntu

This framework is developed on Ubuntu 12.04 x64. An [automated installer](https://github.com/arguslab/ancor-environment) is also available.
- Update packages and install some essential packages

```
sudo apt-get dist-upgrade
sudo apt-get install curl git mongodb-server redis-server
sudo reboot
```

- Ensure your terminal of choice is using bash/zsh as a [login shell](https://rvm.io/support/faq)
- Install RVM

```
curl -L https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
```

- Install Ruby 1.9.3, make it the default Ruby and install Bundler

```
rvm install ruby-1.9.3
rvm use --default ruby-1.9.3
ruby -v
gem install bundler
```

- Configure Git, generate keypair for GitHub

```
git config --global user.name "John Doe"
git config --global user.email "eid@ksu.edu"
git config --global core.editor "vim"
ssh-keygen -t rsa
cat ~/.ssh/id_rsa.pub
```

- Pull repository from GitHub

```
git clone git@github.com:/ancor.git ~/workspace/ancor
cd ~/workspace/ancor
bundle install
```
