## What is ANCOR?

ANCOR is a cloud automation framework that models dependencies between different layers in an
application stack. When instances in one layer changes, the instances in a dependent layer
are notified and reconfigured.

[Detailed Ancor Framework Desciption ](https://dl.dropboxusercontent.com/u/88202830/ANCORAll-in-one.pdf)

[Puppet Manifests' Repository for ANCOR Example Scenarios](https://github.com/arguslab/ancor-puppet)

**Currently ANCOR is a prototype under heavy development. Please don't hesitate to contact the owners if you have any questions or concerns.**

## General Requirements

- In order to use ANCOR, the user needs an Openstack cloud infrastructure that the ANCOR VM can reach.

- The ANCOR VM should be reachable by the instances running on the OpenStack infrastructure (ANCOR VM should run in bridged mode).

- The necessary Puppet manifests that are needed for the system that will be deployed with ANCOR.


## Using and Configuring ANCOR

### Using a preconfigured ANCOR VM

1. **Download** and unzip the **ANCOR VM** for:
  - [VMware Fusion](https://dl.dropboxusercontent.com/u/88202830/ANCOR-Xubuntu-x64.vmwarevm.zip)
  - [VirtualBox](https://dl.dropboxusercontent.com/u/88202830/ANCOR-Xubuntu-x64.ova.zip)

  In case you choose to use a different virtualization infrastructure you might need to convert the available versions. The VM is bridged to the network and therefore the user might be asked if a different NIC is used than the one that it was configured on.

2. In the preconfigured ANCOR virtual machine:
  - Find the Ancor VM's IP address (*e.g.,* run in a terminal: `ifconfig`) 
  - Fill-in the following specific information in `ancor.yml` (`/home/ancor/workspace/ancor/config/ancor.yml`):
    - Open `ancor.yml` file using the shortcut on the Desktop or run in a terminal `vim /home/ancor/Desktop/ancor.yml`
      - Use the ANCOR VM's IP in the **mcollective** AND **puppet** sections of `ancor.yml` 
      - Fill-in OpenStack infrastructure specific information in the **openstack** section of `ancor.yml`

3. Pull the latest version of the ANCOR code and install dependent "libraries".

  Run in terminal:
  ```
  cd ~/workspace/ancor
  git pull
  bundle install
  ```

4. Update the orchestrator component of ANCOR with the new information from "ancor.yml"

  Run in a terminal:
  ```
  bin/setup-mcollective
  ```
  
5. Update the pre-installed ANCOR CLI to the latest version.

  Run in terminal:
  ```
  gem update ancor-cli
  ```

6. Start ANCOR services.

  Run in terminal:
  ```
  bin/start-services
  ```

7. ANCOR is ready for use, ANCOR CLI is preinstalled.

  Run in terminal:
  ```
  ancor
  ```

**In case you would like to try out the available scenarios:**

8. Get the latest CMT (Puppet) manifests and install new CMT modules:

  Run in terminal:
   ```
   sudo -i
   cd /etc/puppet
   git pull
   ./install-modules
   exit
   ```

9. Test the deployment with the default "eCommerce website" example.

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

- Please follow the [automated installer](https://github.com/arguslab/ancor-environment) (includes the [ANCOR CLI](https://github.com/arguslab/ancor-cli) tool)

- If needed, install [ANCOR CLI](https://github.com/arguslab/ancor-cli) on a different host


IMPORTANT! More information and setup options will be made available in the near future.
