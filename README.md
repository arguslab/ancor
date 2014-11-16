## What is ANCOR?

ANCOR is a framework that captures the high-level user requirements and translates them into a working IT system on a cloud infrastructure.

[Compiling Abstract Specifications into Concrete Systems—Bringing Order to the Cloud](https://www.usenix.org/conference/lisa14/conference-program/presentation/unruh)

[Current Ancor Prototype Desciption ](https://dl.dropboxusercontent.com/u/88202830/ANCORAll-in-one.pdf)

[Puppet Manifests' Repository for ANCOR Example Scenarios](https://github.com/arguslab/ancor-puppet)

**Please don't hesitate to contact the owners if you have any questions or concerns.**

## General Requirements

- In order to use ANCOR, the user needs an Openstack cloud infrastructure that the ANCOR VM can reach.

- The ANCOR VM should be reachable by the instances running on the OpenStack infrastructure (ANCOR VM should run in bridged mode).

- The necessary Puppet manifests that are needed for the system that will be deployed with ANCOR.


## Setting Up and Using ANCOR

### Preconfigured ANCOR VM Option

1. **Download** and unzip the **ANCOR VM** for:
  - VMware Fusion - *coming soon (new version under construction)* 
  - VirtualBox - *coming soon (new version under construction)*

  In case you choose to use a different virtualization infrastructure you might need to convert the available versions. The VM is bridged to the network and therefore the user might be asked if a different NIC is used than the one that it was configured on.

2. Setup the communication between ANCOR and the OpenStack deployment. Start ANCOR. 

  Run in terminal:
  ```
  interactive-setup 
  finish-setup 
  start-services 
  ```  

**Testing ANCOR with the default ["eCommerce website"](https://github.com/arguslab/ancor-puppet/tree/master/modules/role/manifests/ecommerce) example:**

  Run in terminal:
  ```
  ancor environment plan /home/ancor/workspace/ancor/spec/fixtures/arml/fullstack.yaml
  ancor environment commit
  ```

### [Vagrant](http://www.vagrantup.com/) Option - *under revision*

Clone the ancor repository. Run in terminal:
```
git clone https://github.com/arguslab/ancor/ && cd ancor
```

If you already have [Vagrant](http://www.vagrantup.com/) installed, simply use `vagrant up` to create
a local development VM for ANCOR.

All necessary ports are forwarded to your host, so you can use your development machine's IP address when
configuring ANCOR. Once the VM is up and running, use `vagrant ssh` to get a shell. From there, change into
the `/vagrant` directory. This directory is shared between the VM and your development machine using the
Shared Folders feature in VirtualBox. Changes in this directory will be shared instantly between the VM
and your development machine.

Once you have a shell in the `/vagrant` directory, run the following to configure and start ANCOR:

1. `cp config/ancor.yml.example config/ancor.yml` to start from the configuration template
2. `vim config/ancor.yml` to configure specifics about your VM and OpenStack infrastructure
3. `bin/setup-mcollective` to install MCollective for ANCOR
4. `bin/start-services` to start the Rails app and Sidekiq worker for ANCOR

### General Setup Instructions
This framework is developed on Ubuntu 12.04 x64.

- Ensure your terminal of choice is using bash/zsh as a [login shell](https://rvm.io/support/faq)

- Please follow the [automated installer](https://github.com/arguslab/ancor-environment) (includes the [ANCOR CLI](https://github.com/arguslab/ancor-cli) tool)

- If needed, install [ANCOR CLI](https://github.com/arguslab/ancor-cli) on a different host
