# Users Guide

Typical ansible-playbook command line.

``` ansible-playbook [-vvv] -e@vars.yaml --become --become-user root --connection local -i inventory_file playbook.yaml ```

Two files - inventory_file and vars.yaml - in the command line is to be updated by the user.

1. inventory_file is used to specify the hosts to deploy the configuration files.

1.1  Sample inventory file
```
[masters]
localhost ansible_user=YOUR_ANSIBLE_USER

[nodes]
localhost ansible_user=YOUR_ANSIBLE_USER
```

1.2  Sample inventory file for the es-ops enabled case
```
[masters]
localhost ansible_user=YOUR_ANSIBLE_USER openshift_logging_use_ops=True

[nodes]
localhost ansible_user=YOUR_ANSIBLE_USER openshift_logging_use_ops=True
```


2. vars.yaml stores variables which are passed to ansible to control the tasks.

   By default rsyslog.conf is placed in /etc.  The "default" contents are stored in ./roles/rsyslog/templates/etc/rsyslog.conf.j2.
   No additional settings required.

Vars.yaml examples for configuring Rsyslog and Fluentd:
   * [Rsyslog vars.yaml examples](https://github.com/linux-system-roles/logging/docs/vars_yaml_rsyslog.md)
   * [Fluentd vars.yaml examples](https://github.com/linux-system-roles/logging/docs/vars_yaml_fluentd.md)

4. Purge local modifications

To purge local modifications prior to setting new ones, set following variable to true in vars.yaml:

```
logging_all_purge: true
```

3. playbook.yaml

```
- name: install and configure logging on the nodes
  hosts: nodes
  roles:
    - role: logging
```

   See the variables section for each variable.


## Variables which could be set in vars.yaml

- `logging_collector` : The supported logging collectors that can be used. Valid options are: `"rsyslog"`, `"fluentd"`. Default to 'rsyslog'.
- `output_plugin` : Output plugin name. It is refferenced in the `logging_logs_list` and then it is described with relevant variable in the `logging_targets_list`.
- `ovirt_env_name` : Only relevant for oVirt environment.  Default to `engine`.

- `logging_mmk8s_token`: Path to token for kubernetes.  Default to "/etc/rsyslog.d/viaq/mmk8s.token"
- `logging_mmk8s_ca_cert`: Path to CA cert for kubernetes.  Default to "/etc/rsyslog.d/viaq/mmk8s.ca.crt"
- `logging_elasticsearch_ca_cert`: Path to CA cert for ElasticSearch.  Default to '/etc/rsyslog.d/viaq/es-ca.crt' for Rsyslog and '/etc/fluentd/elasticsearch_ca_cert.pem' for Fluentd.
- `logging_elasticsearch_cert`: Path to cert for ElasticSearch.  Default to '/etc/rsyslog.d/viaq/es-cert.pem' for Rsyslog and '/etc/fluentd/elasticsearch_client_cert.pem' for Fluentd.
- `logging_elasticsearch_key`: Path to key for ElasticSearch.  Default to "/etc/rsyslog.d/viaq/es-key.pem" for Rsyslog and '/etc/fluentd/elasticsearch_client_key.pem' for Fluentd.

- `logging_logs_list`: The list of logs the role will configure the collection for.

  It is possible to configure the logs in the `logging_logs_list` more than once,
  with different `collector` and `output_plugin`.

- `logging_targets_list`: The list of outputs the role will configure the the logs to be sent to.
  The output parameters are specific to the `output_plugin` that you want to configure and the `logging_collector` that should be configured.

## Additional Resources

   * [README](https://github.com/linux-system-roles/logging/README.md)
   * [Configure Rsyslog](https://github.com/linux-system-roles/logging/docs/configure_rsyslog.md)
   * [Configure Fluentd](https://github.com/linux-system-roles/logging/docs/configure_fluentd.md)

License
-------

Apache License 2.0

