Logging
====================

The `logging` role enables you to deploy required log collectors, logs parsing and adding additional metadata, and shipping them
to the desired location.

Role Variables
--------------

### Configure logging

Before you run this role, you will need to set the following variables:

- `env_name:` (required - default: `"server"`)

  Environment name. Is used to identify where the data was collected from.
  Maximum field length is 49 characters.

- `fluentd_elasticsearch_host:` (required - no default value)

  Address or hostname (FQDN) of the Elasticsearch server host.

In order to set these variable add the required variables to the config.yml
or in the command line.

You don't need to update the configuration file if you wish to use default options.

License
-------

Apache License 2.0

