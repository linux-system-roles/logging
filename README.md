Logging
====================

The `logging` role enables you to deploy required log collectors, logs parsing and adding additional metadata and shipping them
to the desired location.

Role Variables
--------------

### Configure logging

Before you run this role, you will need to set the following variables:

- `env_name:` (required - default: `"engine"`)

  Environment name. Is used to identify data collected source in a single central
  store.
  Maximum field length is 49 characters.

- `fluentd_elasticsearch_host:` (required - no default value)

  Address or hostname (FQDN) of the Elasticsearch server host.

- `env_uuid_logs:` (required - no default value)

  UUID of the project/namespace used to store log records.
  This is used to construct the index name in Elasticsearch.
  For example, if you have env_name: myenvname,
  then in logging OpenShift you will have a project named logs-myenvname.
  You need to get the UUID of this project like this:
  oc get project logs-myenvname -o jsonpath='{.metadata.uid}'

- `fluentd_elasticsearch_ca_cert_path:` (required - no default value)

  The path to the file containing the CA certificate of the CA that issued
  the Elasticsearch SSL server cert.
  Get it from the logging OpenShift machine like this:
  oc get secret logging-fluentd --template='{{index .data "ca"}}' | base64 -d > fluentd-ca
  and use the local_fluentd_elasticsearch_ca_cert_path parameter in your ansible inventory
  or config file to pass in the file to use.

- `fluentd_elasticsearch_client_cert_path:` (required - no default value)

  The path to the file containing the SSL client certificate to use
  with certificate authentication to Elasticsearch.
  Get it from the logging OpenShift machine like this:
  oc get secret logging-fluentd --template='{{index .data "cert"}}' | base64 -d > fluentd-cert
  and use the local_fluentd_elasticsearch_client_cert_path parameter in your ansible inventory
  or config file to pass in the file to use.

- `fluentd_elasticsearch_client_key_path:` (required - no default value)

  The path to the file containing the SSL client key to use
  with certificate authentication to Elasticsearch.
  Get it from the logging OpenShift machine like this:
  oc get secret logging-fluentd --template='{{index .data "key"}}' | base64 -d > fluentd-key
  and use the local_fluentd_elasticsearch_client_key_path parameter in your ansible inventory
  or config file to pass in the file to use.

- `manage_services:` (default: `"true"`)

  If set to true, configured services will be enabled.

- `manage_packages:` (default: `"true"`)

  If set to true, all defined packages will be installed / updated to latest.


In order to set these variable add the required variables to the config.yml
or in the command line.

You don't need to update the configuration file if you wish to use default options.

License
-------

Apache License 2.0

