## fluentd/Client

This role configures fluentd output plugin to send the collected data to a remote metrics store.
It can configure elasticsearch output plugin(Default) or secure_forward plugin.

The available variables for this role are:
- `fluentd_output_plugin:`(default: `"elasticsearch"`)

   The output plugin that will be used to send the data to the remote metrics store.
   Valid options are `"elasticsearch"` to send data to a remote elasticsearch server,
   `"fluentd"` to send data to a remote central fluentd aggregator (mux) and
   `"file"` to send data to local files.

- `env_name:` (default: `"engine"`)

  Environment name. Is used to identify the source of the data collected at the defined destination.
  Maximum field length is 49 characters.

### Relevant when using elasticsearch output plugin

- `fluentd_elasticsearch_host:` (required - default: `""`)

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

- `fluentd_elasticsearch_port:` (default: `"9200"`)

  Port number of the Elasticsearch server.

- `fluentd_elasticsearch_ssl_verify:` (default: `"false"`)

  NOTE: SSL and client cert authentication are always used, regardless of this setting.
  If true, verify that the hostname specified in the Elasticsearch SSL server cert
  matches the fluentd_elasticsearch_host.
  Set to false if the Elasticsearch SSL server cert does not have the correct hostname.

- `fluentd_elasticsearch_target_index_key:` (default: `"index_name"`)

  Name of the field that has the name of the Elasticsearch index to use for this record.

- `fluentd_elasticsearch_remove_keys:` (default: `"index_name"`)

  Name or comma delimited list of fields to remove from the record before sending to Elasticsearch.

- `fluentd_elasticsearch_type_name_logs:` (default: `"com.redhat.viaq.common"`)

  Name of Elasticsearch type for log records.

- `fluentd_elasticsearch_request_timeout_logs:` (default: `"600"`)

  Number of seconds to wait for a response after submitting the bulk index request to Elasticsearch for log records.

### Relevant when using Secure forward output plugin

- `fluentd_fluentd_host:` (required - no default value)

  Address of the fluentd server host.

- `fluentd_keepalive:` (default: `"300"`)

  The duration for keepalive. If this parameter is not specified, keepalive is disabled.

- `fluentd_shared_key:` (required - no default value)

  Shared secret on the central fluentd machine

- `local_fluentd_ca_cert_path:` (required - no default value)

  Path to the cert of the CA used to sign central fluentd cert

The following configurations specify how the buffer plugins should buffer events.
Events are gathered to chunks by the output plugins.

### Relevant when using file output plugin

- `fluentd_file_output_dir:` (default: `"/var/log/fluentd"`)

  Directory of the output files when file output plugin is used.

- `fluentd_logs_file_output:` (default: `"logs-{{ env_name }}"`)

  The file name for logs data.

### Logs buffer configurations

- `fluentd_buffer_chunk_limit_logs:` (default: `"4m"`)

  The size of each chunk. The suffixes “k” (KB), “m” (MB), and “g” (GB) can be used.

- `fluentd_flush_interval_logs:` (default: `"10s"`)

  The interval between data flushes. The default is 10s.
  The suffixes “s” (seconds), “m” (minutes), and “h” (hours) can be used.

- `fluentd_buffer_queue_limit_logs:` (default: `"8"`)

  The length of the chunk queue.

- `fluentd_buffer_queue_full_action_logs:` (default: `"exception"`)

  Control the buffer behaviour when the queue becomes full. 3 modes are supported: exception, block, drop_oldest_chunk.
  For a full documentation about `buffer_queue_full_action` parameter, please refer to fluentd documentation.

- `fluentd_retry_wait_logs:` (default: `"1s"`)

  The initial interval between write retries. The default value is 1.0 seconds.
  The interval doubles (with +/-12.5% randomness) every retry until max_retry_wait is reached.

- `fluentd_retry_limit_logs:` (default: `"17"`)

  The limit on the number of retries before buffered data is discarded. The default value is 17.
  If the limit is reached, buffered data is discarded and the retry interval is reset to its initial value
  (fluentd_retry_wait_logs).

- `fluentd_disable_retry_limit_logs:` (default: `"true"`)

  If true, the value of retry_limit is ignored and there is no limit.

- `fluentd_max_retry_wait_logs:` (default: `"300s"`)

  The maximum interval between write retries.

- `fluentd_flush_at_shutdown_logs:` (default: `"true"`)

  If set to true, Fluentd waits for the buffer to flush at shutdown.
  By default, it is set to true for Memory Buffer and false for File Buffer.

- `fluentd_num_threads_logs:` (default: `"1"`)

  The number of threads to flush the buffer.
  This option can be used to parallelize writes into the output(s) designated by the output plugin.
  Increasing the number of threads improves the flush throughput to hide write / network latency. The default is 1.

- `fluentd_slow_flush_log_threshold_logs:` (default: `"20.0"`)

  The threshold for checking chunk flush performance. The default value is 20.0 seconds.
  Note that parameter type is float, not time.


In order to set these variable add the required variables to the config.yml
or in the command line.

You don't need to update the configuration file if you wish to use default options.
