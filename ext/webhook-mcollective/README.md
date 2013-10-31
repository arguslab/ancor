## MCollective Registration Webhook

The registration plugin in this folder is compatible with:

- MCollective 2.2+
- Ruby 1.8.7+

The registration interval can really long, since the webhook only really cares
about the instance becoming live.

The agent should go in `/usr/share/mcollective/plugins/mcollective/agent/registration.rb`

### Setup

1. Install the registration/meta plugin from `mcollective-plugins`
2. Configure meta registration, registration plugin

### Sample MCollective configuration

```
topicprefix = /topic/
main_collective = mcollective
collectives = mcollective
libdir = /usr/share/mcollective/plugins
logfile = /var/log/mcollective.log
loglevel = info
daemonize = 1

# Plugins
securityprovider = psk
plugin.psk = unset

direct_addressing = 1

connector = rabbitmq
plugin.rabbitmq.vhost = /mcollective
plugin.rabbitmq.pool.size = 1
plugin.rabbitmq.pool.1.host = localhost
plugin.rabbitmq.pool.1.port = 61613
plugin.rabbitmq.pool.1.user = mcollective
plugin.rabbitmq.pool.1.password = marionette

# Registration
registerinterval = 7200
registration = Meta
plugin.registration.endpoint = http://192.168.56.1:3000/webhook/mcollective

# Facts
factsource = yaml
plugin.yaml = /etc/mcollective/facts.yaml
```
