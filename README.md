## What is ANCOR?

ANCOR is a cloud automation framework that models dependencies between different layers in an
application stack. When instances in one layer changes, the instances in a dependent layer
are notified and reconfigured.

Think of it like OpsWorks with dependency management.

## What is ancor-puppet?

To demonstrate zero-downtime changes in clusters, I put together a stack that you'll typically
see in modern web application deployments:

- Rails application (contained in Unicorn + Nginx, Ruby managed by RVM)
- Sidekiq worker application
- MySQL (with master-slave replication)
- Redis (used as a work queue between the Rails app and Sidekiq workers)
- Varnish for load-balancing and caching

The configuration for these components are the minimum necessary to wire everything up. They have
not been tuned, but they do work, if deployed correctly.

Because ANCOR does random port and IP selection, every single service that will be exposed to
other instances will not make assumptions about which port/IP to use.

## Setting Up the Development Environment

### Ubuntu (>= 12.04 LTS)

Update the OS (if needed)
```
sudo apt-get update
sudo apt-get dist-upgrade
sudo reboot
```

Make sure the following packages are installed
```
sudo apt-get install vim curl git htop
```

Download and run RVM
```
curl -L https://get.rvm.io | bash -s stable
source ~/.profile 
rvm
rvm get stable
```

Install Ruby 1.9.3
```
rvm install ruby-1.9.3
```
Teriminal Preferences - Select "Run Command as Login Shell" option
Exit and reopen terminal

```
ruby -v
rvm use --default ruby-1.9.3
```

Install Sublime 3
Download sublime form http://www.sublimetext.com/3
```
sudo dpkg -i /home/andu/Desktop/sublime-text_build-xxxx_amd64.deb
subl
```

Install MongoDB Server
```
sudo apt-get install mongodb-server
```

Install Redis
```
sudo apt-get install redis-server
```

Install bundler
```
gem install bundler
```

Pull repository from GitHub (make sure you have defined a Github public/private keypair)
```
mkdir workspace
cd workspace/
git clone git@github.com:ianunruh/ancor.git
cd ancor/
bundle install
```

Configure Git
```
git config --global user.name "John Doe"
git config --global user.email "eid@ksu.edu"
git config --global core.editor "vim"
```

(Optional) In case terminal colors were disabled after installing RVM, edit ~/.bash_profile:
```
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" && source "$HOME/.bashrc" # Load RVM into a shell session *as a function*
```
