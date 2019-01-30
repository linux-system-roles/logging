linux-system-roles-rsyslog
==========================

# Guidelines for Using Rsyslog Ansible Roles

This is the ansible rsyslog roles to deploy configuration files.

Table of Contents
=================

<!--ts-->
   * [linux-system-roles-rsyslog](#linux-system-roles-rsyslog)
   * [Table of contents](#table-of-contents)
   * [Deploy Rsyslog Configuration Files](#deploy)
      * [Inventory File](#inventory-file)
      * [vars.yaml](#vars)
      * [playbook.yaml](#playbook)
   * [Deployed Results](#results)
      * [rsyslog_viaq_role](#Viaq role)
      * [rsyslog_debops_role](#Debops role)
   * [Variables in vars.yaml](#variables)
      * [Common sub-variables](#common-variables)
      * [Viaq sub-variables](#viaw)
   * [Contents of Roles](#roles)
<!--te-->

Deploy Rsyslog Configuration Files
==================================

Typical ansible-playbook command line.

``` ansible-playbook [-vvv] -e@vars.yaml --become --become-user root -i inventory_file playbook.yaml ```

Two files - inventory_file and vars.yaml - in the command line is to be updated by the user.

Inventory File
--------------
inventory_file is used to specify the hosts to deploy the configuration files.

   Sample inventory file
```
[masters]
localhost ansible_user=YOUR_ANSIBLE_USER

[nodes]
localhost ansible_user=YOUR_ANSIBLE_USER
```

vars.yaml
---------
1. vars.yaml stores variables which are passed to ansible to control the tasks.

   Currently, this rsyslog roles support `viaq` and `debops` input configurations.  Theoretically, both true could be set and the specified configuration files are deployed, but rsyslog does not work properly with the configuration.

   See the variables section for each variable.

   Sample vars.yaml file for the viaq case.
```
rsyslog_unprivileged: False
rsyslog_elasticsearch:
  - name: viaq-elasticsearch
    type: elasticsearch
    logs_collections:
      - name: 'viaq'
        state: 'present'
    server_host: es-hostname
    server_port: 9200
```

2. vars.yaml to configure to handle the inputs from openshift containers
```
rsyslog_unprivileged: False
# If 'viaq-k8s' is in logs collections, logging_mmk8s_* need to be specified.
logging_mmk8s_token: "{{rsyslog_viaq_config_dir}}/mmk8s.token"
logging_mmk8s_ca_cert: "{{rsyslog_viaq_config_dir}}/mmk8s.ca.crt"
# If use_omelasticsearch_cert is True, ca_cert, cert and key in rsyslog_outputs needs to be set.
use_omelasticsearch_cert: True
# If use_local_omelasticsearch_cert is True, local files ca_cert_src, cert_src and key_src will be deployed to the remote host.
use_local_omelasticsearch_cert: True
rsyslog_outputs:
  - name: viaq-elasticsearch
    type: elasticsearch
    rsyslog_logs_collections:
      - name: 'viaq'
        state: 'present'
      - name: 'viaq-k8s'
        state: 'present'
    server_host: logging-es
    server_port: 9200
    index_prefix: project.
    ca_cert: "{{rsyslog_viaq_config_dir}}/es-ca.crt"
    cert: "{{rsyslog_viaq_config_dir}}/es-cert.pem"
    key: "{{rsyslog_viaq_config_dir}}/es-key.pem"
    ca_cert_src : "/path/to/es-ca.crt"
    cert_src : "/path/to/es-cert.pem"
    key_src : "/path/to/es-key.pem"
  - name: viaq-elasticsearch-ops
    type: elasticsearch
    rsyslog_logs_collections:
      - name: 'viaq'
        state: 'present'
      - name: 'viaq-k8s'
        state: `present`
    server_host: logging-es-ops
    server_port: 9200
    index_prefix: .operations.
    ca_cert: "{{rsyslog_viaq_config_dir}}/es-ca.crt"
    cert: "{{rsyslog_viaq_config_dir}}/es-cert.pem"
    key: "{{rsyslog_viaq_config_dir}}/es-key.pem"
    ca_cert_src : "/path/to/es-ca.crt"
    cert_src : "/path/to/es-cert.pem"
    key_src : "/path/to/es-key.pem"
```
The key-value pairs in rsyslog_elasticsearch are used to configure rsyslog to send the logs to the Openshift Aggregated Logging ElasticSearch.  The elements are used in the output elasticsearch configuration 30-elasticsearch.conf as follows (note: not following the abstract syntax):
```
if index_prefix starts with "project." then {
  action( 
      type="omelasticsearch"
      name="viaq-elasticsearch"
      server="logging-es"
      serverport="9200"
      ....
      tls.cacert="/etc/rsyslog.d/viaq/es-ca.crt"
      tls.mycert="/etc/rsyslog.d/viaq/es-cert.pem"
      tls.myprivkey="/etc/rsyslog.d/viaq/es-key.pem"
  )
} else {
  action( 
      type="omelasticsearch"
      name="viaq-elasticsearch-ops"
      server="logging-es-ops"
      serverport="9200"
      ....
      tls.cacert="/etc/rsyslog.d/viaq/es-ca.crt"
      tls.mycert="/etc/rsyslog.d/viaq/es-cert.pem"
      tls.myprivkey="/etc/rsyslog.d/viaq/es-key.pem"
  )
}
```
The order of the list in rsyslog_elasticsearch is important.  The first item is in the first if clause with the index_prefix value and the last item is in the else clause.  Elements in between will be placed with else if clause.

The variables ca_cert, cert and key in rsyslog_elasticsearch specify the paths where the CA certificate, certificate and key are located in the remote host.  The variables ca_cert_src, cert_src, and key_src are paths of them to be deployed to the remote host.


3. vars.yaml to configure custom config files.

   To include existing config files in the new ansible deployment, add the paths to rsyslog_custom_config_files as follows.  The specified files are copied to /etc/rsyslog.d.
```
....
rsyslog_custom_config_files: [ '/path/to/custom_A.conf', '/path/to/custom_B.conf' ]
```

playbook.yaml
-------------

```
- name: install and configure rsyslog on the nodes
  hosts: nodes
  roles:
    - role: rsyslog
      tags: [ 'role::rsyslog' ]
```

Deployed Results
================
Viaq role
-----------------
Once the command-line ansible-playbook is run with `viaq` and `viaq-k8s` in `rsyslog_logs_collections`, the following configuration files will be deployed.

```
/etc/rsyslog.conf
     rsyslog.d/00-global.conf
               05-common-defaults.conf
               10-elasticsearch_main.conf
               10-local-modules.conf
               10-local-viaq-modules.conf
               10-mmk8s.conf
               10-viaq-modules.conf
               20-elasticsearch-templates.conf
               20-viaq-templates.conf
               60-00-elasticsearch.conf.conf
               60-10-mmk8s.conf
               60-20-viaq-formatting.conf
               60-30-elasticsearch.conf.conf
               crio.rulebase
               k8s_container_name.rulebase
               k8s_filename.rulebase
               multiline-json.rulebase
               parse_json.rulebase
               normalize_level.json
               prio_to_level.json
               es-ca.crt
               es-cert.pem
               es-key.pem
               mmk8s.ca.crt
               mmk8s.token
```

Debops role
-------------------
The configuration generated by the `debops` configuration basically reads logs from the local unix socket and outputs to the local files, e.g., in /var/log.  This is the minimum variables to set it up.
```
rsyslog_unprivileged: False
rsyslog_outputs:
  - name: debops exampl config
    rsyslog_logs_collections:
      - name: 'debops'
        state: 'present'

```
In addition, debops role allows to add remote input/output as well as the security over the network.

To redirect the logs to the remote rsyslog servers using the rsyslog rule, you could add rsyslog_forward to the above basic variables.  E.g.,
```
rsyslog_forward: [ '*.crit @@10.10.10.1:514', '*.info @@10.10.10.11:514' ]
```
where @@ means the logs are sent over tcp; if there is one @, they are sent over udp.

To receive remote input, you could add 'network' to rsyslog_capabilities to the basic variables as follows.
```
rsyslog_capabilities: [ 'network' ]
```
It will configure imudp as well as imptcp.

To put logs from the remote input in the separate files, e.g., /var/log/remote/hosts/%HOSTNAME%/*.log, 'remote-files' could be added to rsyslog_capabilities.
```
rsyslog_capabilities: [ 'network', 'remote-files' ]
```

Finally, to make the network communication safe, enable rsyslog_pki and add 'tls' to rsyslog_capabilities.
```
rsyslog_outputs:
rsyslog_pki: true
rsyslog_outputs:
  - name: debops exampl config
    rsyslog_logs_collections:
      - name: 'debops'
        state: 'present'
        rsyslog_capabilities: [ 'network', 'remote-files', 'tls' ]
        rsyslog_forward: [ '*.crit @@10.10.10.1:514', '*.info @@10.10.10.11:514' ]
```
It will set the ca_cert, cert and key paths to the configuration and enable receiving and forwarding logs over TLS.

Once ansible-playbook is run with debops in rsyslog_logs_collection set to true and having full rsyslog_capabilities [ 'network', 'remote-files', 'tls' ], the following configuration files will be deployed.
```
/etc/rsyslog.conf
     rsyslog.d/00-global.conf
               05-common-defaults.conf
               10-local-modules.conf
               10-network-modules.conf
               20-remote-forward.system
               20-templates.conf
               40-cron.system
               40-dynamic-cron.remote
               50-default-rulesets.conf
               50-default-rules.system
               50-dynamic-logs.remote
               90-network-input.conf
               zz-stop.remote
```

If rsyslog_outputs is not set, the default rsyslog.conf is placed in /etc.  The "default" contents are stored in ./roles/rsyslog/templates/etc/rsyslog.conf.j2.

WARNING: If both 'debops' and 'viaq' logs_collections are set , conflicting configurations are generated and rsyslog would not work as expected.

Variables in vars.yaml
======================

- `rsyslog_enabled` : When 'True' rsyslog role will deploy specified configuration file set. Default to 'True'.
- `rsyslog_pki` : When 'True' pki related variables are configured.  In addition, if 'tls' is included in 'rsyslog_capabilities', it enables to forward logs over TLS.  Default to 'False'.
- `rsyslog_capabilities` : List of capabilities to configure.  [ 'network', 'remote-files', 'tls' ] are predefined.

Common sub-variables
--------------------
- `rsyslog_system_log_dir`: System log directory.  Default to '/var/log'.
- `rsyslog_config_dir`: Parent directory of the configuration files. Used inside of the config files.  Default to '/etc/rsyslog.d'.
- `rsyslog_parent_config_dir`: Directory to store rsyslog.conf.  Default to '/etc'.
- `rsyslog_files_config_dir`: Directory to locate rsyslog.conf. Used in deploying the config files.  Default to '/etc/rsyslog.d'.
- `rsyslog_mode`:  Mode for the config files.  Default to '0400'
- `rsyslog_max_message_size`: Maximum supported message size.  Default to 8k.
- `rsyslog_work_dir`: Working directory.  Default to '/var/lib/rsyslog'.
- `rsyslog_purge_original_conf`: By default, the Rsyslog configuration files are applied on top of pre-existing configuration files. To purge local files prior to setting new ones, set rsyslog_purge_original_conf variable to 'True', it will move all Rsyslog configuration files to a backup directory before deploying the new configuration files. Defaults to 'False'.
- `rsyslog_backup_dir`: By default, the Rsyslog backs up the pre-existing configuration files in a temp dir as tar-gz format - /tmp/rsyslog.d-XXXXXX/backup.tgz.  By setting a path to rsyslog_backup_dir, the path is used as the backup directory.  Note that the directory should exist and have the permission to create the backup file both in the file mode and the selinux.
- `rsyslog_custom_config_files`: List of custom configuration files are deployed to /etc/rsyslog.d.  The format is an array which element is the full path to each custom configuration file.  Default to none.
- `rsyslog_unprivileged`: If set to True, you could specify non-root rsyslog_user and rsyslog_group.  If ansible_distribution is one of "CentOS", "RedHat", and "Fedora", default to True.  Otherwise, False.
- `rsyslog_user`: Owner user of rsyslogd.  Default to 'syslog' if rsyslog_unprivileged is True.  Otherwise, 'root'.
- `rsyslog_group`: Owner group of rsyslogd.  Default to 'syslog' if rsyslog_unprivileged is True.  Otherwise, 'root'.
- `rsyslog_purge_confs`: If set to 'True', existing files in `rsyslog_config_dir` are purged.  Default to 'False'.
- `use_rsyslog_image`: If set to 'True', the rsyslog is run in the OpenShift container.

Viaq sub-variables
------------------
- `rsyslog_viaq_config_dir`: Directory to store viaq configuration files.  Default to '/etc/rsyslog.d/viaq'.
- `rsyslog_viaq_log_dir`: Viaq log directory.  Default to '/var/log/containers'.
- `logging_mmk8s_token`: Path to token for kubernetes.  Default to "/etc/rsyslog.d/viaq/mmk8s.token"
- `logging_mmk8s_ca_cert`: Path to CA cert for kubernetes.  Default to "/etc/rsyslog.d/viaq/mmk8s.ca.crt"
- `use_omelasticsearch_cert` : If set to `True`, omelasticsearch is configured to use the certificates specified in rsyslog_elasticsearch.  Default to `False`.
- `use_local_omelasticsearch_cert` : If set to `True`, local files ca_cert_src, cert_src and key_src in rsyslog_elasticsearch will be deployed to the remote host.

- `rsyslog_elasticsearch`: A set of following variables to specify output elasticsearch configurations. It could be an array if multiple elasticsearch clusters to be configured.
   If set to `True`, ca_cert_src, cert_src and key_src must be set in each `rsyslog_elasticsearch` element. Otherwise, the deployment fails. Default to `False`.
  - `name`: Name of the elasticsearch element.
  - `server_host`: Hostname elasticsearch is running on.
  - `server_port`: Port number elasticsearch is listening to.
  - `index_prefix`: Elasticsearch index prefix the particular log is to be indexed.
  - `ca_cert`: Path to CA cert for ElasticSearch.  Default to '/etc/rsyslog.d/elasticsearch/es-ca.crt'
  - `cert`: Path to cert for ElasticSearch.  Default to '/etc/rsyslog.d/elasticsearc/es-cert.pem'
  - `key`: Path to key for ElasticSearch.  Default to "/etc/rsyslog.d/elasticsearch/es-key.pem"
  - `ca_cert_src`: Path to the local CA cert file to deploy for ElasticSearch.
  - `cert_src`: Path to the local cert file to deploy for ElasticSearch.
  - `key_src`: Path to the local key file to deploy for ElasticSearch.

Contents of Roles
=================
It contains the framework and data for the configuration files to be deployed.

The basic framework borrowed from debops.rsyslog and adjusted to the RHEL/Fedora specification.

- templates have 2 template files, rsyslog.conf.j2 and rules.conf.j2.  The former is used to generate /etc/rsyslog.conf and the latter is for the other configuration files including mmnormalize rulebase and formatter which will be placed in ```{{rsyslog_config_dir}}``` (default to /etc/rsyslog.d) and its subdirectories.

- tasks/main.yaml contains the sceries of tasks to deploy specified set of configuration files.

If viaq is in rsyslog_logs_collections, the following tasks are executed.
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
If debops is in rsyslog_logs_collections the following tasks are executed.
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

-defaults/main.yaml defines variables to switch the deployment paths, variables to specify the locations to deploy and the configurations to be deployed.

Describing how the configuration files are defined to be deployed using the viaq case.

Viaq configuration files are defined in {{rsyslog_viaq_rules}} in /roles/input_rols/viaq/defaults/main.yaml.  The set is made from the generic modules{rsyslog_conf_global_options, rsyslog_conf_local_modules, rsyslog_conf_network_modules, rsyslog_conf_common} and viaq specific configurations.

To make a new configuration file installed in addition to the current {{rsyslog_viaq_rules}}, create an rsyslog config item based on the following skelton and add the title {{rsyslog_conf_yourname}} to {{rsyslog_viaq_rules}}.
```
rsyslog_conf_yourname:

  - name: 'somename'
    type: choose one of 'global' 'module' 'modules' 'template' 'templates' 'output' 'service' 'rule' 'rules' 'ruleset' 'input'
    path: path this configuration file to be placed if it's not {{rsyslog_config_dir}}.
    nocomment: 'true' if you want to avoid "# Ansible managed" to be added at the top of the file.
    sections:

      - options: |-
          # COMMENTS
          your rsyslog configuration

```
Type is for adding prefix to the file name to manage the order of the configuration loaded.  In the viaq case, only .conf files set type 'modules', 'output', and 'template' are set.  By setting 'modules', for instance, prefix "10-" is added to the "name".  I.e., if the name is "mmk8s" and type is "modules", the file name "10-mmk8s.conf" is constructed.  'template' is mapped to '20-'; 'output' is mapped to '30-'.  The digits ensure the configuration files are loaded in the correct order.  The type and prefix mapping is defined in rsyslog_weight_map in ./roles/rsyslog/defaults/main.yaml.

If the deploy destination is other than {{rsyslog_config_dir}}, the path is to be set to path.

By default, the generated configuration file starts with a comment "# Ansible managed".  It could break some type of configurations.  For instance, "version=2" must be the first line in a rulebase file.  To avoid having "# Ansible managed", set true to nocomment.

Some full path configuration may be referred from other configuration file, e.g., 20-viaq_formattiong.conf refers parse_json.rulebase as follows.
```
action(type="mmnormalize" ruleBase="{{ rsyslog_viaq_config_dir }}/parse_json.rulebase" variable="$!MESSAGE")
```
In this case, prefix is not needed.  Thus, by setting exact filename, the named configuration file "parse_json.rulebase" is generated.
```
  - name: 'parse_json'
    filename: 'parse_json.rulebase'
    nocomment: 'true'
    path: '{{rsyslog_viaq_config_dir }}'
    sections:

      - options: |-
          version=2
          rule=:%.:json%
```
