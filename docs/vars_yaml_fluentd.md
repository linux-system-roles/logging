Vars.yaml - Fluentd
===================

This role runs dependent fluentd roles, Roles list is located in the meta directory.
In this document we explain how to configure vars.yaml to deploy Rsyslog.

Table of contents
=================

<!--ts-->
   * [Rsyslog Vars.yaml](#rsyslog-vars.yaml)
   * [Table of contents](#table-of-contents)
   * [Default Deployment](#default-deployment)
   * [Custom Configuration Files](#custom-configuration-files)
   * [oVirt Configuration Files](#ovirt-configuration-files)
      * [oVirt Hosts Configurations](#ovirt-hosts-configurations)
      * [oVirt Engine Configurations](#ovirt-engine-configurations)
   * [Vars.yaml Variables](#vars.yaml-variables)
   * [Contents of Role](#contents-of-role)
   * [For Develpers](#for-develpers)
   * [Additional Resources](#additional-resources)
<!--te-->

Default Deployment
==================

Custom Configuration Files
==========================
vars.yaml to configure custom config files.

   To include existing config files in the new ansible deployment, add the paths to fluentd_custom_config_files as follows.  The specified files are copied to /etc/fluentd/config.d/  .
```
fluentd__enabled: true
....
fluentd_custom_config_files: [ '/path/to/custom_A.conf', '/path/to/custom_B.conf' ]
```

oVirt Configuration Files
========================


## oVirt Hosts Configurations
```
logging_logs_list:
  - ovirt_vdsm_log:
      logging_collector: fluentd
      output_plugin: elasticsearch_ovirt

logging_targets_list:
  - elasticsearch_ovirt:
      output_plugin: elasticsearch
      elasticsearch_host: hostname.example.com
      ovirt_env_name: engine
      ovirt_env_uuid:
      # If use_omelasticsearch_cert is True, logging_elasticsearch_* need to be specified.
      use_omelastcsearch_cert: True
      logging_elasticsearch_ca_cert: "{{fluentd_viaq_config_dir}}/es-ca.crt"
      logging_elasticsearch_cert: "{{fluentd_viaq_config_dir}}/es-cert.pem"
      logging_elasticsearch_key: "{{fluentd_viaq_config_dir}}/es-key.pem"
```

## oVirt Engine Configurations
```
logging_logs_list:
  - ovirt_engine_log:
      logging_collector: fluentd
      output_plugin: elasticsearch_ovirt

logging_targets_list:
  - elasticsearch_ovirt:
      output_plugin: elasticsearch
      elasticsearch_host: hostname.example.com
      ovirt_env_name: engine
      ovirt_env_uuid:
      # If use_omelasticsearch_cert is True, logging_elasticsearch_* need to be specified.
      use_omelastcsearch_cert: True
      logging_elasticsearch_ca_cert: "{{fluentd_viaq_config_dir}}/es-ca.crt"
      logging_elasticsearch_cert: "{{fluentd_viaq_config_dir}}/es-cert.pem"
      logging_elasticsearch_key: "{{fluentd_viaq_config_dir}}/es-key.pem"
```

Vars.yaml Variables
===================

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


## Fluentd variables which could be set in vars.yaml

- `fluentd_config_parts_dir`: Path to the directory containing Fluentd  configuration snippets. Default to '/etc/fluentd/config.d'
- `fluentd_config_dir`: Path to the Fluentd configuration directory.  Default to '/etc/fluentd'
- `fluentd_config_file`: Path to the main Fluentd configuration file.  Default to '/etc/fluentd/fluent.conf'

- `fluentd_shared_key`: Shared secret key for SSL connections when .
- `fluentd_ca_cert_path`: File mode for Fluentd configuration files.  Default to '/etc/fluentd/ca_cert.pem'.
- `fluentd_ca_cert`:Content of an x509 certificate that will be used to identify the server to clients.


Contents of Role
================



Additional Resources
====================

   * [README](https://github.com/linux-system-roles/logging/README.md)
   * [User Guide](https://github.com/linux-system-roles/logging/docs/README.md)
   * [Rsyslog vars.yaml examples](https://github.com/linux-system-roles/logging/docs/vars_yaml_rsyslog.md)


License
-------

Apache License 2.0

