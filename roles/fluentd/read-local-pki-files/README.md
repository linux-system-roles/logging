## fluentd/Read-local-pki-files

This role reads fluentd pki files from a local file.

The available variables for this role are:

- `local_fluentd_ca_cert_path:`  (default: `"fluentd_ca_cert.pem"`)

  The path to the Fluentd server certificate authority certificate
  on the control machine.

- `local_fluentd_elasticsearch_ca_cert_path`  (default: `"fluentd_elasticsearch_ca_cert.pem"`)

  The path to the file containing the CA certificate of the CA that issued
  the Elasticsearch SSL server cert.

- `local_fluentd_elasticsearch_client_cert_path`  (default: `"fluentd_elasticsearch_cert.pem"`)

  The path to the file containing the SSL client certificate to use
  with certificate authentication to Elasticsearch.

- `local_fluentd_elasticsearch_client_key_path`  (default: `"fluentd_elasticsearch_key.pem"`)

  The path to the file containing the SSL client key to use
  with certificate authentication to Elasticsearch.
