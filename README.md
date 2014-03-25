## What is ANCOR?

ANCOR is a cloud automation framework that models dependencies between different layers in an
application stack. When instances in one layer changes, the instances in a dependent layer
are notified and reconfigured.

## General Requirements

- In order to use ANCOR, the user needs an Openstack cloud infrastructure that the ANCOR VM can reach.

- The ANCOR VM should be reachable by the instances running on the OpenStack infrastructure (ANCOR VM should run in bridged mode).

- The necessary Puppet manifests that are needed for the system that will be deployed with ANCOR.


## Using and Configuring ANCOR

### Using a preconfigured ANCOR VM

1. **Download** and unzip the **ANCOR VM** for:
  - [VMware Fusion](http://people.cis.ksu.edu/~bardasag/ANCOR-Xubuntu-x64.vmwarevm.zip)
  - [VirtualBox](https://dl.dropboxusercontent.com/u/88202830/ANCOR-Xubuntu-x64.ova.zip)

  In case you choose to use a different virtualization infrastructure you might need to convert the available versions. The VM is bridged to the network and therefore the user might be asked if a different NIC is used than the one that it was configured on.

2. In the preconfigured virtual machine, fill-in the information specific to your OpenStack infrastructure in "ancor.yml" (`/home/ancor/workspace/ancor/config/ancor.yml`). You can also use the link on the Desktop.

  Run in a terminal:
  ```
  vim /home/ancor/Desktop/ancor.yml
  ```

  *Hint*: Run ifconfig to find out the ANCOR VM's IP address. **Use this address in the "mcollective" AND "puppet" section of "ancor.yml"**

3. Update the orchestrator component of ANCOR with the new information from "ancor.yml"

  Run in a terminal:
  ```
  /home/ancor/workspace/ancor/bin/setup-mcollective
  ```

4. Start ANCOR services

  Run in terminal:
  ```
  cd ~/workspace/ancor
  bin/start-services
  ```

5. ANCOR is ready for use, ANCOR CLI is preinstalled.

  Run in terminal:
  ```
  ancor
  ```

6. OPTIONAL: Test the deployment with the default "eCommerce website" example.

  Run in terminal:
  ```
  ancor environment plan /home/ancor/workspace/ancor/spec/fixtures/arml/fullstack.yaml
  ancor environment commit
  ```

### Using Vagrant

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

- Please follow the [automated installer](https://github.com/arguslab/ancor-environment)

- Install [ANCOR CLI](https://github.com/arguslab/ancor-cli) (preferably on the same VM)


IMPORTANT! More information and setup options will be made available in the near future.
