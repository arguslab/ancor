
### What is ANCOR?

ANCOR is a cloud automation framework that models dependencies between different layers in an
application stack. When instances in one layer changes, the instances in a dependent layer
are notified and reconfigured.

Think of it like OpsWorks with dependency management.

### What is ancor-puppet?

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
