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

## _MTD CBITS: Moving Target Defense for Cloud-Based IT Systems_ Resources
- [Blogging Website and Hadoop Scenario Experiments, Supporting Chinese Remainder Theorem Use Cases Proofs, and Openstack Filter Scheduler Configuration](https://github.com/arguslab/ancor/blob/master/supplementary-material/additional-resources.pdf)
- [Python implementation for an "attack windows calculator"](https://github.com/arguslab/ancor/tree/master/supplementary-material/attack-windows-calculator)


## General Requirements
- In order to use MTD CBITS and/or ANCOR, the user needs an OpenStack cloud infrastructure that the VM hosting 
MTD CBITS/ANCOR  can reach.

- The MTD CBITS/ANCOR VM should be reachable by the instances running on the OpenStack infrastructure (i.e., VM should run in bridged mode).

- The necessary Puppet manifests that are needed for the system that will be deployed with MTD CBITS or ANCOR.


## Setting Up and Using MTD CBITS and ANCOR

### Preconfigured MTD CBITS/ANCOR VM

1. **Download** the **MTD CBITS/ANCOR VM**:
 - Source -- [OVA format (works with Virtual Box, VMware products, etc.)](https://drive.google.com/open?id=0B0vt6z9-IhD9SHZQRkdaeDZIUmc)

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

**Testing MTD CBITS and ANCOR with a basic ["Drupal deployment"](https://github.com/arguslab/ancor-puppet/tree/master/modules/role/manifests/drupal) example:**

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
