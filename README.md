## What is ANCOR?

ANCOR is a cloud automation framework that models dependencies between different layers in an
application stack. When instances in one layer changes, the instances in a dependent layer
are notified and reconfigured.

## Developing ANCOR

### Operating System

This framework is developed on Ubuntu 12.04 x64. 

### Setup Instructions

- Ensure your terminal of choice is using bash/zsh as a [login shell](https://rvm.io/support/faq)

- Please follow the [automated installer](https://github.com/arguslab/ancor-environment) 

- Install ANCOR CLI (preferably on the same VM)

```
git clone git@github.com:arguslab/ancor-cli.git
cd ancor-cli
bundle install
```

IMPORTANT! More information and setup options will be made available in the near future.
