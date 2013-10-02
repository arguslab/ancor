## Overview

Typical initial deployment task tree:

- provision network
    - provision instance
        - update security rules
        - initialize instance
            - push configuration

Tasks on the same level can be run in parallel. Tasks on nested levels run in
serial.

The following operations take more than a few seconds to do:

- Provisioning an instance *(~15 seconds, up to minutes)*

    We don't necessarily have to wait on this operation, but it is possible for
    an instance to fail during provisioning. OpenStack does not notify us when
    an instance is created or when the process results in an error, which pretty
    much forces us to poll the Nova API for status updates.

- Bootstrapping an instance *(~120 seconds, up to 10 minutes)*

    MCollective supports "registration", where instances respond to a fanout poll
    every so often (30 seconds by default). The registration agent could call a
    webhook upon registration.

- Configuring an instance with Puppet *(~30 seconds, up to 10 minutes)*

    Puppet agents report to the Puppet master once they have completed a run. The
    reporter could call a webhook after a run has finished.

These times all depend on network speed and congestion.

Ideally, we don't want entire threads that are blocked with polling. Therefore,
there needs to be a way to leave a task and come back to it later.

There are two general points of waiting:

- Before the task is considered finished, it has to wait for something
- Before the task can start, it has to wait for something
