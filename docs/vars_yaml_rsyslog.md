Vars.yaml - Rsyslog
===================

Vars.yaml stores variables which are passed to ansible to control the tasks.
In this document we explain how to configure vars.yaml to deploy Rsyslog.

Table of contents
=================

<!--ts-->
   * [Rsyslog Vars.yaml](#rsyslog-vars.yaml)
   * [Table of contents](#table-of-contents)
   * [Default Deployment](#default-deployment)
   * [Custom Configuration Files](#custom-configuration-files)
   * [Viaq Configuration Files](#viaq-configuration-files)
      * [Standarad Configuration](#standarad-configuration)
      * [OpenShift Containers Logs](#collect-openShift-containers-logs)
      * [Example Configurations](#example-configurations)
   * [Vars.yaml Variables](#vars.yaml-variables)
   * [Contents of Role](#contents-of-role)
   * [For Develpers](#for-develpers)
   * [Additional Resources](#additional-resources)
<!--te-->



Default Deployment
==================

By default rsyslog.conf is placed in /etc.  The "default" contents are stored in ./roles/rsyslog/templates/etc/rsyslog.conf.j2.
**No additional settings required.**


   See the variables section for each variable.


Custom Configuration Files
==========================
vars.yaml to configure custom config files.

   To include existing config files in the new ansible deployment, add the paths to rsyslog__custom_config_files as follows.  The specified files are copied to /etc/rsyslog.d.
```
rsyslog__enabled: true
....
rsyslog__custom_config_files: [ '/path/to/custom_A.conf', '/path/to/custom_B.conf' ]
```

Viaq Configuration Files
========================

   Currently, the rsyslog roles support 2 deployment variables, rsyslog__viaq and rsyslog__example.
   I.e., there are 3 sets of deployment - rsyslog__viaq: true, rsyslog__example: true, and both false.
   Theoretically, both true could be set and the specified configuration files are deployed, but rsyslog does not work properly with the configuration.

## Standarad Configuration 

```
rsyslog__enabled: true
# install viaq packages & config files
rsyslog__viaq: true
rsyslog__capabilities: [ 'viaq' ]
rsyslog__group: root
rsyslog__user: root

logging_logs_list:
  - {logging_viaq: True, output_plugin: elasticsearch_viaq}

logging_targets_list:
elasticsearch_viaq:
  logging_collector: rsyslog # Optional, since this is the default.
  output_plugin: elasticsearch
  elasticsearch_server_host: es_hostname
  elasticsearch_server_port: 9200
  # If 'viaq-k8s' is in rsyslog__capabilities, logging_mmk8s_* need to be specified.
  logging_mmk8s_token: "{{rsyslog__viaq_config_dir}}/mmk8s.token"
  logging_mmk8s_ca_cert: "{{rsyslog__viaq_config_dir}}/mmk8s.ca.crt"
  # If use_omelasticsearch_cert is True, logging_elasticsearch_* need to be specified.
  use_omelasticsearch_cert: True
  logging_elasticsearch_ca_cert: "{{rsyslog__viaq_config_dir}}/es-ca.crt"
  logging_elasticsearch_cert: "{{rsyslog__viaq_config_dir}}/es-cert.pem"
  logging_elasticsearch_key: "{{rsyslog__viaq_config_dir}}/es-key.pem"
```

## OpenShift Containers Logs

```
rsyslog__enabled: true
# install viaq packages & config files
rsyslog__viaq: true
rsyslog__capabilities: [ 'viaq', 'viaq-k8s' ]
rsyslog__group: root
rsyslog__user: root


logging_logs_list:
  - {logging_viaq_mmk8s: True, output_plugin: elasticsearch_viaq}

logging_targets_list:
elasticsearch_viaq:
  logging_collector: rsyslog # Optional, since this is the default.
  output_plugin: elasticsearch
  elasticsearch_server_host: es_hostname
  elasticsearch_server_port: 9200
  # If 'viaq-k8s' is in rsyslog__capabilities, logging_mmk8s_* need to be specified.
  logging_mmk8s_token: "{{rsyslog__viaq_config_dir}}/mmk8s.token"
  logging_mmk8s_ca_cert: "{{rsyslog__viaq_config_dir}}/mmk8s.ca.crt"
  # If use_omelasticsearch_cert is True, logging_elasticsearch_* need to be specified.
  use_omelasticsearch_cert: True
  logging_elasticsearch_ca_cert: "{{rsyslog__viaq_config_dir}}/es-ca.crt"
  logging_elasticsearch_cert: "{{rsyslog__viaq_config_dir}}/es-cert.pem"
  logging_elasticsearch_key: "{{rsyslog__viaq_config_dir}}/es-key.pem"

```

   Once ansible-playbook is run with rsyslog__viaq: true, the following configuration files will be deployed.

```
/etc/rsyslog.conf
     rsyslog.d/00-global.conf
               05-common-defaults.conf
               10-local-modules.conf
               10-viaq_main.conf
               viaq/10-mmk8s.conf
                    20-viaq_formatting.conf
                    30-elasticsearch.conf
                    k8s_container_name.rulebase
                    k8s_filename.rulebase
                    parse_json.rulebase
                    normalize_level.json
                    prio_to_level.json
                    es-ca.crt
                    es-cert.pem
                    es-key.pem
                    mmk8s.ca.crt
                    mmk8s.token
```

## Example Configurations

```
rsyslog__enabled: true
# install example packages & config files
rsyslog__example: true
rsyslog__capabilities: [ 'network', 'remote-files', 'tls' ]
rsyslog__group: root
rsyslog__user: root
```

   Once ansible-playbook is run with rsyslog__example: true, the following configuration files will be deployed.

```
/etc/rsyslog.conf
     rsyslog.d/00-global.conf
               10-local-modules.conf
               10-network-modules.conf
               05-common-defaults.conf
               20-templates.conf
               20-remote-forward.system
               50-default-rulesets.conf
               50-default-rules.system
               40-cron.system
               90-network-input.conf
               40-dynamic-cron.remote
               50-dynamic-logs.remote
               zz-stop.remote
```

    WARNING: If both variables are set to true, conflicting configurations are generated and rsyslog would not work as expected.

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

- `rsyslog__enabled` : When 'True' rsyslog role will deploy specified configuration file set. Default to 'True'.
- `rsyslog__viaq` : When 'True' rsyslog role will deploy the viaq configuration set.  In this case, rsyslog works as a collector of OpenShift logs, normalizes them, then sends to the ElasticSearch.  Default to 'False'.
- `rsyslog__example` : When 'True' rsyslog role will deploy the example configuration set.  Default to 'False'.
 **Note:** Theoretically, both `rsyslog__viaq` and `rsyslog__example` could be set to `true` and the specified configuration files are deployed, but rsyslog does not work properly with the configuration.

- `rsyslog__capabilities` : List of capabilities to configure.  [ 'network', 'remote-files', 'tls', 'viaq', 'viaq-k8s' ] are predefined.

- `rsyslog__system_log_dir`: System log directory.  Default to '/var/log'.
- `rsyslog__config_dir`: Directory to store configuration files.  Default to '/etc/rsyslog.d'.
- `rsyslog__viaq_config_dir`: Directory to store viaq configuration files.  Default to '/etc/rsyslog.d/viaq'.
- `rsyslog__viaq_log_dir`: Viaq log directory.  Default to '/var/log/containers'.
- `rsyslog__work_dir`: Working directory.  Default to '/var/lib/rsyslog'.


Contents of Role
================
It contains the framework and data for the configuration files to be deployed.

The basic framework borrowed from debops.rsyslog and adjusted to the RHEL/Fedora specification.

- templates have 2 template files, rsyslog.conf.j2 and rules.conf.j2.  The former is used to generate /etc/rsyslog.conf and the latter is for the other configuration files including mmnormalize rulebase and formatter which will be placed in ```{{rsyslog__config_dir}}``` (default to /etc/rsyslog.d) and its subdirectories.

- tasks/main.yaml contains the sceries of tasks to deploy specified set of configuration files.

If rsyslog__viaq is true, the following tasks are executed.
```
TASK [rsyslog : Install/Update required packages]
TASK [rsyslog : Create required system group]
TASK [rsyslog : Create required system user]
TASK [rsyslog : Create a work directory]
TASK [rsyslog : Create a temp directory for rsyslog.d backup]
TASK [rsyslog : Set backup dir name]
TASK [rsyslog : Create a backup dir]
TASK [rsyslog : Moving the contents of /etc/rsyslog.d to the backup dir]
TASK [rsyslog : create rsyslog viaq subdir]
TASK [rsyslog : Update directory and file permissions]
TASK [rsyslog : Generate main rsyslog configuration]
TASK [rsyslog : Generate viaq configuration files in rsyslog.d]
TASK [rsyslog : Generate rsyslog viaq configuration files in rsyslog.d/viaq]
```
If rsyslog__example is true, the following tasks are executed.
```
TASK [rsyslog : Install/Update required packages]
TASK [rsyslog : Create required system group]
TASK [rsyslog : Create required system user]
TASK [rsyslog : Create a work directory]
TASK [rsyslog : Create a temp directory for rsyslog.d backup]
TASK [rsyslog : Set backup dir name]
TASK [rsyslog : Create a backup dir]
TASK [rsyslog : Moving the contents of /etc/rsyslog.d to the backup dir]
TASK [rsyslog : create rsyslog viaq subdir]
TASK [rsyslog : Update directory and file permissions]
TASK [rsyslog : Generate main rsyslog configuration]
TASK [rsyslog : Generate exaple configuration files in rsyslog.d]
```
WARNING: Pre-existing rsyslog.conf and configuration files in /etc/rsyslog.d are moved to the backup directory /tmp/rsyslog.d-XXXXXX.  If the pre-existing files need to be merged with the newly deployed files, you need to do it manually.

-rsyslog/defaults/main.yaml defines variables to switch the deployment paths, variables to specify the locations to deploy and the configurations to be deployed.

Describing how the configuration files are defined to be deployed using the viaq case.



For Develpers
=============

Viaq configuration files are defined in {{rsyslog__viaq_rules}} in defaults/main.yaml.  The set is made from the generic modules{rsyslog__conf_global_options, rsyslog__conf_local_modules, rsyslog__conf_network_modules, rsyslog__conf_common} and viaq specific configurations.

To make a new configuration file installed in addition to the current {{rsyslog__viaq_rules}}, create an rsyslog config item based on the following skelton and add the title {{rsyslog__conf_yourname}} to {{rsyslog__viaq_rules}}.
```

rsyslog__conf_yourname:

  - name: 'somename'
    type: choose one of 'global' 'module' 'modules' 'template' 'templates' 'output' 'service' 'rule' 'rules' 'ruleset' 'input'
	path: path this configuration file to be placed if it's not {{rsyslog__config_dir}}.
	nocomment: 'true' if you want to avoid "# Ansible managed" to be added at the top of the file.
    sections:

      - options: |-
          # COMMENTS
          your rsyslog configuration

```
Type is for adding prefix to the file name to manage the order of the configuration loaded.  In the viaq case, only .conf files set type 'modules', 'output', and 'template' are set.  By setting 'modules', for instance, prefix "10-" is added to the "name".  I.e., if the name is "mmk8s" and type is "modules", the file name "10-mmk8s.conf" is constructed.  'template' is mapped to '20-'; 'output' is mapped to '30-'.  The digits ensure the configuration files are loaded in the correct order.  The type and prefix mapping is defined in rsyslog__weight_map in ./roles/rsyslog/defaults/main.yaml.

If the deploy destination is other than {{rsyslog__config_dir}}, the path is to be set to path.

By default, the generated configuration file starts with a comment "# Ansible managed".  It could break some type of configurations.  For instance, "version=2" must be the first line in a rulebase file.  To avoid having "# Ansible managed", set true to nocomment.

Some full path configuration may be referred from other configuration file, e.g., 20-viaq_formattiong.conf refers parse_json.rulebase as follows.
```
action(type="mmnormalize" ruleBase="{{ rsyslog__viaq_config_dir }}/parse_json.rulebase" variable="$!MESSAGE")
```
In this case, prefix is not needed.  Thus, by setting exact filename, the named configuration file "parse_json.rulebase" is generated.
```
  - name: 'parse_json'
    filename: 'parse_json.rulebase'
    nocomment: 'true'
    path: '{{rsyslog__viaq_config_dir }}'
    sections:

      - options: |-
          version=2
          rule=:%.:json%
```

Additional Resources
====================

   * [README](https://github.com/linux-system-roles/logging/README.md)
   * [User Guide](https://github.com/linux-system-roles/logging/docs/README.md)
   * [Fluentd vars.yaml examples](https://github.com/linux-system-roles/logging/docs/vars_yaml_fluentd.md)

License
-------

Apache License 2.0

