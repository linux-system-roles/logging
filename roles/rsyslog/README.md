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
      * [vars.yml](#vars)
      * [playbook.yml](#playbook)
   * [Variables in vars.yml](#variables)
      * [Common sub-variables](#common-variables)
      * [Viaq sub-variables](#viaw)
   * [Contents of Roles](#roles)
<!--te-->

Deploy Rsyslog Configuration Files
==================================

Typical ansible-playbook command line.

``` ansible-playbook [-vvv] -e@vars.yml --become --become-user root -i inventory_file playbook.yml ```

Two files - inventory_file and vars.yml - in the command line are to be updated by the user.

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

vars.yml
---------
vars.yml stores variables which are passed to ansible to control the tasks.  The contents of this file could be merged into the inventory file.

Currently, the logging role supports four types of logs collections ([inputs](https://github.com/linux-system-roles/logging/tree/master/roles/rsyslog/tasks/inputs/)): `basics`, `files`, `ovirt`, and `viaq`.  And 3 types of log outputs ([outputs](https://github.com/linux-system-roles/logging/tree/master/roles/rsyslog/tasks/outputs/)): `elasticsearch`, `files`, and `forwards`.  To deploy configuration files with these inputs and outputs, first specify the outputs as `logging_outputs`, then inputs as `logging_inputs`.  For define the flow from inputs to outputs, use `logging_flows`.  The `logging_flows` is made from, `name`, `inputs`, and `outputs`, where `inputs` is a list of `logging_inputs name` values and `outputs` is a list of `logging_outputs name` values.

The following example defines 3 type of inputs input_nameA, B, C and 2 types of outputs output_name0 and 1. The log messages from input_nameA and B are sent to the output_name0; the log messages from inputC are sent to output_name1.
```
logging_enabled: true
logging_outputs:
  -name: <output_name0>
   type: <output_type0>
  -name: <output_name1>
   type: <output_type1>
logging_inputs:
  - name: <input_nameA>
    type: <input_typeA>
  - name: <input_nameB>
    type: <input_typeB>
  - name: <input_nameC>
    type: <input_typeC>
logging_flows:
  - name: <flowX>
    inputs: [<input_nameA>, <input_nameB>]
    outputs: [<output_name0>]
  - name: <flowY>
    inputs: [<input_nameC>]
    outputs: [<output_name1>]
```
To make an effect with the following setting, vars.yml has to have `logging_enabled: true`.  Unless `logging_enabled` is set to true, LSR/Logging does not deploy rsyslog config files.

See the [variables section](#variables) for each variable.

vars.yml examples
------------------

**0. Deploying default /etc/rsyslog.conf.**
```
logging_enabled: true
```

**1. Overriding existing /etc/rsyslog.conf and files in /etc/rsyslog.d with default rsyslog.conf.  Pre-existing config files are copied to the directory specified by `rsyslog_backup_dir`.**
```
logging_enabled: true
logging_purge_original_conf: true
rsyslog_backup_dir: /tmp/rsyslog_backup
```

**2. Deploying basic LSR/Logging config files in /etc/rsyslog.d, which handle inputs from the local system and outputs into the local files, which actions are predefined. Pre-existing config files are copied to the directory specified by `rsyslog_backup_dir`.**
```
logging_enabled: true
logging_purge_confs: true
rsyslog_backup_dir: /tmp/rsyslog_backup
logging_outputs:
  - name: local-files
    type: files
logging_inputs:
  - name: system-input
    type: basics
logging_flows:
  - name: flow0
    inputs: [system-input]
    outputs: [local-files]
```
If inputs are specified, but no flows or outputs are specified, the default is to write the input to the predefined system log files e.g. /var/log/messages.
```
logging_purge_confs: true
logging_inputs:
  - name: system-input
    type: basics
```

**3. Deploying basic LSR/Logging config files in /etc/rsyslog.d, which handle inputs from the remote rsyslog and outputs into the local files per host.
```
logging_purge_confs: true
rsyslog_backup_dir: /tmp/rsyslog_backup
logging_outputs:
  - name: files_output0
    type: files
    severity: info
    exclude: [authpriv.none, auth.none, cron.none, mail.none]
    path: /var/log/messages
  - name: files_output1
    type: files
    severity: emerg
    path: :omusrmsg:*
  - name: files_output2
    <<snip>>
logging_inputs:
  - name: system-input
    type: basics
logging_flows:
  - name: flow0
    inputs: [system-input]
    outputs: [files_output0, files_output1, files_output2, ...]
```

**4. Deploying basic LSR/Logging config files in /etc/rsyslog.d, which handle inputs from the local system and remote rsyslog and outputs into the local files.**
```
        logging_outputs:
          - name: remote_files_output
            type: remote_files
        logging_inputs:
          - name: remote_udp_input
            type: remote
            udp_port: 11514
          - name: remote_tcp_input
            type: remote
            tcp_port: 22514
        logging_flows:
          - name: flow_0
            inputs: [remote_udp_input, remote_tcp_input]
            outputs: [remote_files_output]
```
If more detailed outputs to be configured instead of using the default paths, they are configurable as follows.
```
        logging_outputs:
          - name: remote_files_output0
            type: remote_files
            remote_log_path: /var/log/remote/%HOSTNAME%/%PROGRAMNAME:::secpath-replace%.log
            severity: info
            exclude: [authpriv.none]
          - name: remote_files_output1
            type: remote_files
            remote_sub_path: others/%HOSTNAME%/%PROGRAMNAME:::secpath-replace%.log
            facility: authpriv
        logging_inputs:
          - name: remote_udp_input
            type: remote
            udp_port: 11514
          - name: remote_tcp_input
            type: remote
            tcp_port: 22514
        logging_flows:
          - name: flow_0
            inputs: [remote_udp_input, remote_tcp_input]
            outputs: [remote_files_output0, remote_files_output1]
```

**5. Deploying basic LSR/Logging config files in /etc/rsyslog.d, which forwards the local system logs to the remote rsyslog.
```
logging_enabled: true
logging_purge_confs: true
logging_outputs:
  - name: output-forwards0
    type: forwards
    severity: info
    protocol: udp
    target: 10.11.12.13
    port: 514
  - name: output-forwards1
    type: forwards
    facility: mail
    protocol: tcp
    target: 10.20.30.40
    port: 514
logging_inputs:
  - name: basic-input
    type: basics
logging_flows:
  - name: flows0
    inputs: [basic-input]
    outputs: [output-forwards0, output-forwards1]
```

**6. Sample vars.yml file for the viaq case. (not implemented yet) **
```
logging_enabled: true
logging_outputs:
  - name: viaq-elasticsearch
    type: elasticsearch
    server_host: es-hostname
    server_port: 9200
logging_inputs:
  - name: viaq-input
    type: viaq
logging_flows:
  - name: flow0
    inputs: [viaq]
    outputs: [viaq-elasticsearch]
```

playbook.yml
-------------

```
- name: install and configure rsyslog on the nodes
  hosts: nodes
  roles:
    - role: rsyslog
      tags: [ 'role::rsyslog' ]
```

Variables in vars.yml
======================

- `logging_enabled` : When 'true', rsyslog role will deploy specified configuration file set. Default to 'true'.
- `logging_encryption`: Specifying an encryption. One of `none`, `ptcp`, `tls`, `gtls`, `gnutls`, and `openssl`. Default to `ptcp`.
                        Note: `none`=`ptcp`, `tls`=`gtls`=`gnutls`.
                        When logging_encryption is _not_ `ptcp`, rsyslog_pki_path`, `rsyslog_pki_realm`, `rsyslog_pki_ca`, `rsyslog_pki_crt`, `rsyslog_pki_key` are configured.
- `logging_mark`: Mark message periodically by immark, if set to `true`. Default to `false`.
- `logging_mark_interval`: Interval for `logging_mark` in seconds. Default to 3600.

Common sub-variables
--------------------
- `rsyslog_backup_dir`: By default, the Rsyslog backs up the pre-existing configuration files in a temp dir as tar-gz format - /tmp/rsyslog.d-XXXXXX/backup.tgz.  By setting a path to `rsyslog_backup_dir`, the path is used as the backup directory.  Note that the directory should exist and have the permission to create the backup file both in the file mode and the selinux.
- `rsyslog_config_dir`: Directory to store configuration files.  Default to '/etc/rsyslog.d'.
- `rsyslog_custom_config_files`: List of custom configuration files are deployed to /etc/rsyslog.d.  The format is an array which element is the full path to each custom configuration file.  Default to none.
- `rsyslog_in_image`: Specifies if the target host is a container and use rsyslog in the image. Default to false.
- `rsyslog_work_dir`: Working directory.  Default to '/var/lib/rsyslog'.

Elasticsearch, Files, Remote_files, and Forwards outputs sub-variables
----------------------------------
- `elasticsearch`: array of dictionary to specify the parameters to forward the log messages to elasticsearch.
   ```
   - name: <unique_name>
     type: elasticsearch
     server_host: <elasticsearch hostname>
     server_port: <elasticsearch port, default to 9200>
     index_prefix: <prefix to use in the elasticsearch index file>
     input_type: <input type, e.g., ovirt>
     retryfailures: on|off, default to on
     ca_cert: <path to ca.crt>
     cert: <path to es-cert.pem>
     key: <path to es-key.pem>
   ```
- `files`: array of dictionary to specify the facility and severity filter and the full path to store logs satisfying the filter.  It takes the sub-variables - `name`, `facility`, `severity`, `exclude`, and `path`.  Unless the name and the path are given, the element is skipped.
Files output format
   ```
   - name: <unique_name>
     type: files
     facility: <facility_in_text, e.g., "mail"; default to "*">
     severity: <severity_in_text, e.g., "info"; default to "*">
     exclude: <excluded list; default to none>
     path: </full/path/to/file/to/store/the/logs; MUST EXIST>
   ```
- `forwards`: array of dictionary to specify the facility and severity filter and the host and port to forward logs satisfying the filter.  It takes the sub-variables - `name`, `facility`, `severity`, `exclude`, `protocol`, `target`, and `port`.  Unless the name and the target are given, the element is skipped.
Forwards output format
   ```
   - name: <unique_name>
     type: forwards
     facility: <facility_in_text, e.g., "mail"; default to "*">
     severity: <severity_in_text, e.g., "info"; default to "*">
     exclude: <excluded list; default to none>
     protocol: <tcp_or_udp; default to "tcp">
     target: <target_host_name_or_ip_address; MUST EXIST>
     port: <port_number; default to 514>
   ```
- `remote_files`: array of dictionary to specify the facility and severity filter and the full path or the relative path to store logs satisfying the filter.  It takes the sub-variables - `name`, `facility`, `severity`, `exclude`, and `remote_log_path` or `remote_sub_path`.  Unless the name and one of remote_log_path or remote_sub_path are given, the default remote_files is configured.
Remote_files output format
   ```
   - name: <unique_name>
     type: files
     facility: <facility_in_text, e.g., "mail"; default to "*">
     severity: <severity_in_text, e.g., "info"; default to "*">
     exclude: <excluded list, e.g., [mail.none, auth.none]; default to none>
     remote_log_path: </full/path/to/file/to/store/the/logs>
     remote_sub_path: <relative/path/from/`logging_system_log_dir`/to/file/to/store/the/logs>
   ```

Basics inputs sub-variables
------------------------------
- `kernel_message`: load `imklog`.
- `use_imuxsock`: use `imuxsock` instead of `imjournal`.
- `rsyslog_imjournal_ratelimit_burst`: set to imjournal RateLimit.Burst. Default to 20000.
- `rsyslog_imjournal_ratelimit_interval`: set to imjournal RateLimit.Interval. Default to 600.
- `rsyslog_imjournal_persist_state_interval`: set to imjournal PersistStateInterval. Default to 10.

Files inputs sub-variables
------------------------------
- `rsyslog_input_log_path`: File name to be read by the imfile plugin. The value should be full path. Wildcard '*' is allowed in the path.  Default to `/var/log/containers/*.log`

Remote inputs sub-variables
- `udp_port`: if the port number is given, rsyslog is configured to listen at the udp port number. Default to 514.
- `tcp_port`: if the port number is given, rsyslog is configured to listen at the tcp port number. Default to 514.
- `tcp_tls_port`: if the port number is given, rsyslog is configured to listen at the tls tcp port number. Default to 6514.

Viaq inputs sub-variables
-----------------------------
- `rsyslog_viaq_log_dir`: Viaq log directory.  Default to '/var/log/containers'.
- `logging_mmk8s_token`: Path to token for kubernetes.  Default to "/etc/rsyslog.d/mmk8s.token"
- `logging_mmk8s_ca_cert`: Path to CA cert for kubernetes.  Default to "/etc/rsyslog.d/mmk8s.ca.crt"
- `use_omelasticsearch_cert` : If set to 'true', omelasticsearch is configured to use the certificates specified in the elasticsearch type logging_outputs.  Default to 'false'.
- `use_local_omelasticsearch_cert` : If set to 'true', local files ca_cert_src, cert_src and key_src in the elasticsearch type logging_outputs will be deployed to the remote host.

- For the elasticsearch type logging_outputs, a set of following variables are to specify output elasticsearch configurations. It could be an array if multiple elasticsearch clusters to be configured.
   If set to 'true', ca_cert_src, cert_src and key_src must be set in each elasticsearch element. Otherwise, the deployment fails. Default to 'false'.
  - `name`: Name of the elasticsearch element.
  - `server_host`: Hostname elasticsearch is running on.
  - `server_port`: Port number elasticsearch is listening to.
  - `index_prefix`: Elasticsearch index prefix the particular log is to be indexed.
  - `input_type`: Specifying the input type. Type `ovirt` and `viaq` are supported. Default to `ovirt`.
  - `retryfailures`: Specifying whether retries or not in case of failure. on or off.  Default to on.
  - `ca_cert`: Path to CA cert for Elasticsearch.  Default to '/etc/rsyslog.d/es-ca.crt'
  - `cert`: Path to cert for Elasticsearch.  Default to '/etc/rsyslog.d/es-cert.pem'
  - `key`: Path to key for Elasticsearch.  Default to "/etc/rsyslog.d/es-key.pem"
  - `ca_cert_src`: Path to the local CA cert file to deploy for Elasticsearch.
  - `cert_src`: Path to the local cert file to deploy for Elasticsearch.
  - `key_src`: Path to the local key file to deploy for Elasticsearch.

Contents of Roles
=================
It contains the framework and data for the configuration files to be deployed.

The basic framework is based on debops.rsyslog and adjusted to the RHEL/Fedora specification.

- templates have 2 types of template files, one is rules.conf.j2 which is a generic template to produce every configuration file. The others, output_elasticsearch.j2, output_forwards.j2, output_files.j2, input_template.j2, ovirt_input_template.j2, etc. are for each input and output configuration file.

- tasks/main.yml contains the series of tasks to deploy specified set of configuration files.

WARNING: Pre-existing rsyslog.conf and configuration files in /etc/rsyslog.d are moved to the backup directory /tmp/rsyslog.d-XXXXXX.  If the pre-existing files need to be merged with the newly deployed files, you need to do it manually.

-defaults/main.yml defines variables to switch the deployment paths, variables to specify the locations to deploy and the configurations to be deployed.

Describing how the configuration files are defined to be deployed using the viaq case.

Viaq configuration files are defined in {{ __rsyslog_viaq_rules }} in /roles/input_roles/viaq/defaults/main.yml.  The set is made from the generic modules{__rsyslog_conf_global_options, __rsyslog_conf_local_modules, __rsyslog_conf_common_defaults} and viaq specific configurations.

If you are a role developer and planning to add a new default configuration to the role depo, create an rsyslog config item based on the following skeleton and add the title {{ __rsyslog_conf_yourname }} to {{ __rsyslog_viaq_rules }}.
```
__rsyslog_conf_yourname:

  - name: some_name
    type: choose one of 'global' 'module' 'modules' 'template' 'templates' 'output' 'service' 'rule' 'rules' 'ruleset' 'input'
    path: path this configuration file to be placed if it's not {{ rsyslog_config_dir }}.
    nocomment: 'true' if you want to avoid "# Ansible managed" to be added at the top of the file.
    sections:

      - options: |-
          # COMMENTS
          your rsyslog configuration

```
Type is for adding prefix to the file name to manage the order of the configuration loaded.  In the viaq case, only .conf files set type 'modules', 'output', and 'template' are set.  By setting 'modules', for instance, prefix "10-" is added to the "name".  I.e., if the name is "mmk8s" and type is "modules", the file name "10-mmk8s.conf" is constructed.  'template' is mapped to '20-'; 'output' is mapped to '30-'.  The digits ensure the configuration files are loaded in the correct order.  The type and prefix mapping is defined in rsyslog_weight_map in ./roles/rsyslog/defaults/main.yml.

If the deploy destination is other than {{ rsyslog_config_dir }}, the path is to be set to path.

By default, the generated configuration file starts with a comment "# Ansible managed".  It could break some type of configurations.  For instance, "version=2" must be the first line in a rulebase file.  To avoid having "# Ansible managed", set true to nocomment.

Some full path configuration may be referred from other configuration file, e.g., 20-viaq_formatting.conf refers parse_json.rulebase as follows.
```
action(type="mmnormalize" ruleBase="{{ rsyslog_config_dir }}/parse_json.rulebase" variable="$!MESSAGE")
```
In this case, prefix is not needed.  Thus, by setting exact filename, the named configuration file "parse_json.rulebase" is generated.
```
  - name: parse_json
    filename: parse_json.rulebase
    nocomment: true
    path: '{{ rsyslog_config_dir }}'
    sections:

      - options: |-
          version=2
          rule=:%.:json%
```
