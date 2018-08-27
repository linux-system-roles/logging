## fluentd/fluentd-inputs

This role configures fluentd to parse the selected logs
and add additional metadata before sending them to the defined target.

For logs collection and processing you can either add a configuration file for Rsyslog or Fluentd or
select from the optional predefined logs to collect.

The following are the available pre-defined logs:

- `collect_ovirt_vdsm_log:`(default: `"false"`)
  Set this parameter to `true` if you wish to collect the oVirt vdsm.log.

- `collect_ovirt_engine_log:`(default: `"false"`)
  Set this parameter to `true` if you wish to collect the oVirt engine.log.


The following metadata is added to the oVirt logs:

- `hostname`

  The hostname that the metric is collected from.

- `ipaddr4`

  The ipv4 address of the host the metric is collected from.

- `service`

  The name for the collected log file.

- `tag`

  This field can be used for several tags.
  Currently it holds the prefixs of the elasticsearch index the logs will be saved to. Like, project.ovirt-logs-<ovirt_env_name>


In order to set the required action there are the following variables


- `fluentd_pos_files_dir:`  (default: `"/var/lib/fluentd/pos-files"`)

  Path to the Fluentd configuration directory.

- `fluentd_ovirt_vdsm_log_pos_file:` (default: `"{{ fluentd_pos_files_dir }}/ovirt-vdsm.log.pos"`)

  Path to the oVirt vdsm.log pos file.

- `fluentd_pos_files_mode:` (default: `"0640"`)

  File mode for Fluentd configuration files.

- `fluentd_pos_files_dir_mode:` (default: `"0750"`)

  File mode for Fluentd configuration directories.
