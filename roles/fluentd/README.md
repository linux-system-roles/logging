## fluentd

This role runs dependent fluentd roles, Roles list is located in the meta directory.

It is run as part of the `Configure Metrics` play and the default `configure` tag.
It also includes the `restart fluentd` handler.


The available variables for this role are:

- `fluentd_service_name:`  (default: `"fluentd"`)

  Fluentd service name.

- `fluentd_config_dir:` (default: `"/etc/fluentd"`)

  Path to the Fluentd configuration directory.

- `fluentd_config_file:` (default: `"{{ fluentd_config_dir }}/fluent.conf"`)

  Path to the main Fluentd configuration file.

- `fluentd_config_parts_dir:` (default: `"/etc/fluentd"`)

  Path to the directory containing Fluentd configuration snippets.

- `fluentd_owner:` (default: `"root"`)

  User that will own Fluentd config files.

- `fluentd_group:` (default: `"root"`)

  Group that will own Fluentd config files.

- `fluentd_config_mode:` (default: `"0640"`)

  File mode for Fluentd configuration files.

- `fluentd_config_dir_mode:` (default: `"0750"`)

  File mode for Fluentd configuration directories.

- `fluentd_use_ssl:` (default: `"false"`)

  Set to true if Fluentd should use SSL.

- `fluentd_shared_key:`

  Shared secret key for SSL connections.

- `fluentd_ca_cert_path:` (default: `"{{ fluentd_config_dir }}/ca_cert.pem"`)

  File mode for Fluentd configuration files.

- `fluentd_ca_cert:`

  Content of an x509 certificate that will be used to identify the server to clients.

# Relevant only to elasticsearch output plugin

- `fluentd_elasticsearch_ca_cert_path:` (default: `'{{ fluentd_config_dir }}/elasticsearch_ca_cert.pem'`)

  Where to find the Fluentd CA certificate used to communicate with Elasticsearch

- `fluentd_elasticsearch_client_cert_path:` (default: `'{{ fluentd_config_dir }}/elasticsearch_client_cert.pem'`)

  Where to find the Fluentd client certificate used to communicate with Elasticsearch

- `fluentd_elasticsearch_client_key_path:` (default: `'{{ fluentd_config_dir }}/elasticsearch_client_key.pem'`)

  Where to find the Fluentd client certificate used to communicate with Elasticsearch

- `fluentd_elasticsearch_ca_cert:`

  Content of an x509 Fluentd Elasticsearch CA certificate that will be used to identify the
  server to clients.

- `fluentd_elasticsearch_client_cert:`

  Content of an x509 Fluentd Elasticsearch client certificate that will be used to
  authenicate to Elasticsearch.

- `fluentd_elasticsearch_client_key:`

  Content of an x509 Fluentd Elasticsearch client key that will be used to
  authenicate to Elasticsearch.


In order to set these variable add the required variables to the config.yml
or in the command line.

You don't need to update the configuration file if you wish to use default options.
