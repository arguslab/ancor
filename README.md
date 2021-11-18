## What is MTD CBITS?
Moving Target Defense for Cloud-Based IT Systems (MTD CBITS) is a platform that 
automatically adapts multiple aspects of the network’s logical and physical configuration. 
The platform is targeting OpenStack and is built on top of ANCOR. 
ANCOR is a framework that captures the high-level user requirements and translates them into 
a working IT system on a cloud infrastructure. 

Useful information:
- [MTD CBITS: Moving Target Defense for Cloud-Based IT Systems](http://people.cs.ksu.edu/~sdeloach/publications/Conference/esorics17_cbits.pdf)
- [Compiling Abstract Specifications into Concrete Systems – Bringing Order to the Cloud](https://www.usenix.org/conference/lisa14/conference-program/presentation/unruh)
- [Puppet Manifests' Repository for ANCOR Example Scenarios](https://github.com/arguslab/ancor-puppet)

**Please don't hesitate to contact the authors if you have any questions or concerns.**

## Resources for _MTD CBITS: Moving Target Defense for Cloud-Based IT Systems_
- [Blogging Website and Hadoop Scenario Experiments, Supporting Chinese Remainder Theorem Use Cases Proofs, and Openstack Filter Scheduler Configuration](https://github.com/arguslab/ancor/blob/master/supplementary-material/additional-resources.pdf)
- [Python implementation for an "attack windows calculator"](https://github.com/arguslab/ancor/tree/master/supplementary-material/attack-windows-calculator)


## General Requirements
- In order to use MTD CBITS and/or ANCOR, the user needs an OpenStack cloud infrastructure (extensively tested on Icehouse release) that the VM hosting MTD CBITS/ANCOR  can reach.

- The MTD CBITS/ANCOR VM should be reachable by the instances running on the OpenStack infrastructure (i.e., VM should run in bridged mode).

- The necessary Puppet manifests that are needed for the system that will be deployed with MTD CBITS or ANCOR.



## Setting Up and Using MTD CBITS and ANCOR

### Option 1 - General Setup Instructions 
(The underlying ANCOR framework was extensively tested on Ubuntu 12.04 x64.)

- Ensure your terminal of choice is using bash/zsh as a [login shell](https://rvm.io/support/faq)

- Please follow the [automated installer](https://github.com/arguslab/ancor-environment) (includes the [ANCOR CLI](https://github.com/arguslab/ancor-cli) tool)

- Run in terminal: Change directory into the ANCOR folder to configure and start ANCOR
  ```bin/interactive-setup; bin/setup-mcollective; bin/start-services```
  
- If needed, install [ANCOR CLI](https://github.com/arguslab/ancor-cli) on a different host



### Option 2 - Preconfigured MTD CBITS/ANCOR VM

1. **Download** the **MTD CBITS/ANCOR VM**:
 - Source -- [OVA format (works with Virtual Box, VMware products, etc.)](https://drive.google.com/file/d/0B0vt6z9-IhD9X3ktbXZyOGJVajQ/view?usp=sharing&resourcekey=0-jYif6W7JaA88c9wZQbHJwQ)

 Default credentials - user: **ancor** password: **ancor**

 The virtual machine is bridged to the network and therefore the user might be warned that a different NIC is used than the one that it was configured on.

2. Setup the communication between the preconfigured VM and the OpenStack deployment. Start MTD CBITS/ANCOR ... 

  Run in terminal:
  ```
  cd ~/workspace/ancor
  bin/interactive-setup
  bin/finish-setup
  bin/start-services
  ```  

** Testing MTD CBITS and ANCOR with a basic ["Drupal deployment"](https://github.com/arguslab/ancor-puppet/tree/master/modules/role/manifests/drupal) example:**

  Run in terminal:
  ```
  ancor environment plan /home/ancor/workspace/ancor/spec/fixtures/arml/drupal.yaml
  ancor environment commit
  ```
For more information about the available sample scenarios please check [Puppet Manifests' Repository for MTD CBITS and ANCOR Example Scenarios](https://github.com/arguslab/ancor-puppet)

For more features (e.g., adding, removing, replacing instances) run in terminal: 
```
ancor
```

### Option 3 - Using [Vagrant](http://www.vagrantup.com/)

1. Install [Vagrant](http://www.vagrantup.com/)
2. Clone the MTD CBITS/ANCOR repository. Run in terminal: 

 ```
 git clone https://github.com/arguslab/ancor/ && cd ancor
 ```
3. Create a local development VM for MTD CBITS and ANCOR. All necessary ports are forwarded to your host, so you can use your development machine's IP address when configuring MTD CBITS and/or ANCOR. Run in terminal: `vagrant up`

4. Once the VM is up and running, run in terminal:`vagrant ssh`
5. Run the following commands inside the VM to configure and start ANCOR:

  `cd /vagrant` to change into the ANCOR directory 
  This directory is shared between the VM and your host using the
  Shared Folders feature in VirtualBox. Changes in this directory will be shared instantly between the VM
  and your host.

  `bin/interactive-setup` to start from the configuration template

  `bin/setup-mcollective` to install MCollective for ANCOR

  `bin/start-services` to start the Rails app and Sidekiq worker for ANCOR
6. Test MTD CBITS and ANCOR with a basic ["Drupal deployment"](https://github.com/arguslab/ancor-puppet/tree/master/modules/role/manifests/drupal) example:

 ```
 ancor environment plan /vagrant/spec/fixtures/arml/drupal.yaml; ancor environment commit
 ```
