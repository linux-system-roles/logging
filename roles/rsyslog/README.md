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

Currently, the role supports 3 types of logs collections ([input_roles](https://github.com/linux-system-roles/logging/tree/master/roles/rsyslog/roles/input_roles/)): `basics`, `ovirt`, and `viaq`.  And 3 types of log outputs ([output_roles](https://github.com/linux-system-roles/logging/tree/master/roles/rsyslog/roles/output_roles/)): `elasticsearch`, `files`, and `forwards`.  To deploy rsyslog configuration files with these input and output roles, first specify the output_role as `logging_outputs`, then input_role as `logging_inputs` in each `logging_outputs`.  Multiple input roles could be required based on the use cases.

To make an effect with the following setting, vars.yml has to have `logging_enabled: true`.  Unless `logging_enabled` is set to true, LSR/Logging does not deploy rsyslog config files.
```
logging_enabled: true
rsyslog_default: false
logging_outputs:
  -name: <output_role_name0>
   type: <output_type0>
  -name: <output_role_name1>
   type: <output_type1>
logging_inputs:
  - name: <input_role_nameA>
    type: <input_role_typeA>
  - name: <input_role_nameB>
    type: <input_role_typeB>
  - name: <input_role_nameC>
    type: <input_role_typeC>
logging_flows:
  - name: <flowX>
    inputs: [<input_role_nameA>, <input_role_nameB>]
    outputs: [<output_role_name0>]
  - name: <flowY>
    inputs: [<input_role_nameC>]
    outputs: [<output_role_name1>]
```

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
rsyslog_purge_original_conf: true
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
logging_enabled: true
logging_purge_confs: true
logging_inputs:
  - name: system-input
    type: basics
```

**3. Deploying basic LSR/Logging config files in /etc/rsyslog.d, which handle inputs from the local system and remote rsyslog and outputs into the local files.**
```
logging_enabled: true
rsyslog_capabilities: [ 'network', 'remote-files' ]
logging_purge_confs: true
logging_outputs:
  - name: local-files
    type: files
logging_inputs:
  - name: system-and-remote-input
    type: basics
logging_flows:
  - name: flow0
    inputs: [system-and-remote-input]
    outputs: [local-files]
```

**4. Deploying basic LSR/Logging config files in /etc/rsyslog.d, which forwards the local system logs to the remote rsyslog.
```
logging_enabled: true
rsyslog_default: false
rsyslog_purge_original_conf: true
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

**5. Sample vars.yml file for the viaq case. (not implemented yet) **
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

**6. vars.yml to configure to handle the inputs from openshift containers. (obsolete) **
```
logging_enabled: true
# If 'viaq-k8s' is in logs collections, logging_mmk8s_* need to be specified.
logging_mmk8s_token: "{{ rsyslog_config_dir }}/mmk8s.token"
logging_mmk8s_ca_cert: "{{ rsyslog_config_dir }}/mmk8s.ca.crt"
# If use_omelasticsearch_cert is true, ca_cert, cert and key in logging_outputs needs to be set.
use_omelasticsearch_cert: true
# If use_local_omelasticsearch_cert is true, local files ca_cert_src, cert_src and key_src will be deployed to the remote host.
use_local_omelasticsearch_cert: true
logging_outputs:
  - name: viaq-elasticsearch
    type: elasticsearch
    logging_inputs:
      - name: viaq-input
        type: viaq
        state: present
      - name: viaq-k8s-input'
        type: viaq-k8s'
        state: present
    server_host: logging-es
    server_port: 9200
    index_prefix: project.
    ca_cert: "{{ rsyslog_config_dir }}/es-ca.crt"
    cert: "{{ rsyslog_config_dir }}/es-cert.pem"
    key: "{{ rsyslog_config_dir }}/es-key.pem"
    ca_cert_src : "/path/to/es-ca.crt"
    cert_src : "/path/to/es-cert.pem"
    key_src : "/path/to/es-key.pem"
  - name: viaq-elasticsearch-ops
    type: elasticsearch
    logging_inputs:
      - name: viaq-input
        type: viaq
        state: present
      - name: viaq-k8s-input
        type: viaq-k8s
        state: present
    server_host: logging-es-ops
    server_port: 9200
    index_prefix: .operations.
    ca_cert: "{{ rsyslog_config_dir }}/es-ca.crt"
    cert: "{{ rsyslog_config_dir }}/es-cert.pem"
    key: "{{ rsyslog_config_dir }}/es-key.pem"
    ca_cert_src : "/path/to/es-ca.crt"
    cert_src : "/path/to/es-cert.pem"
    key_src : "/path/to/es-key.pem"
```
The key-value pairs in the elasticsearch type logging_outputs are used to configure rsyslog to send the logs to the Openshift Aggregated Logging ElasticSearch.  The elements are used in the output elasticsearch configuration 30-elasticsearch.conf as follows (note: not following the abstract syntax):
```
if index_prefix starts with "project." then {
  action( 
      type="omelasticsearch"
      name="viaq-elasticsearch"
      server="logging-es"
      serverport="9200"
      ....
      tls.cacert="/etc/rsyslog.d/es-ca.crt"
      tls.mycert="/etc/rsyslog.d/es-cert.pem"
      tls.myprivkey="/etc/rsyslog.d/es-key.pem"
  )
} else {
  action( 
      type="omelasticsearch"
      name="viaq-elasticsearch-ops"
      server="logging-es-ops"
      serverport="9200"
      ....
      tls.cacert="/etc/rsyslog.d/es-ca.crt"
      tls.mycert="/etc/rsyslog.d/es-cert.pem"
      tls.myprivkey="/etc/rsyslog.d/es-key.pem"
  )
}
```
The order of the list in the elasticsearch type logging_outputs is important.  The first item is in the first if clause with the index_prefix value and the last item is in the else clause.  Elements in between will be placed with else if clause.

The variables ca_cert, cert and key in the elasticsearch type logging_outputs specify the paths where the CA certificate, certificate and key are located in the remote host.  The variables ca_cert_src, cert_src, and key_src are paths of them to be deployed to the remote host.

**7. vars.yml to configure custom config files.**

   To include existing config files in the new ansible deployment, add the paths to `rsyslog_custom_config_files` as follows.  The specified files are copied to /etc/rsyslog.d.
```
....
rsyslog_custom_config_files: [ '/path/to/custom_A.conf', '/path/to/custom_B.conf' ]
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
- `rsyslog_capabilities` : List of capabilities to configure.  [ 'network', 'remote-files', 'tls', 'gnutls', 'kernel-message', 'mark' ] are predefined.
   To receive remote input, you could add 'network' to `rsyslog_capabilities`, which will configure imudp as well as imptcp.
   To put logs from the remote input in the separate files, 'remote-files' is to be added to `rsyslog_capabilities`.
   To make the network communication safe, enable `rsyslog_pki` and add `tls` to `rsyslog_capabilities`.
   To log all kernel messages to the console, add `kernel-message` to `rsyslog_capabilities`.
   To add `-- MARK --` message every hour, add `mark` to `rsyslog_capabilities`.
- `rsyslog_default`: If set as `true`, rsyslog.conf will be configured with default configurations and rules.
- `rsyslog_pki` : When 'true', pki related variables are configured, which are `rsyslog_pki_path`, `rsyslog_pki_realm`, `rsyslog_pki_ca`, `rsyslog_pki_crt`, `rsyslog_pki_key`.  In addition, if 'tls' is included in `rsyslog_capabilities`, it enables to forward logs over TLS.  Default to 'false'.
- `rsyslog_send_over_tls_only` : When 'true', insecure connection is not allowed.  I.e., it requires `tls` in `rsyslog_capabilities`.  Default to 'false'.

Common sub-variables
--------------------
- `rsyslog_backup_dir`: By default, the Rsyslog backs up the pre-existing configuration files in a temp dir as tar-gz format - /tmp/rsyslog.d-XXXXXX/backup.tgz.  By setting a path to `rsyslog_backup_dir`, the path is used as the backup directory.  Note that the directory should exist and have the permission to create the backup file both in the file mode and the selinux.
- `rsyslog_config_dir`: Directory to store configuration files.  Default to '/etc/rsyslog.d'.
- `rsyslog_custom_config_files`: List of custom configuration files are deployed to /etc/rsyslog.d.  The format is an array which element is the full path to each custom configuration file.  Default to none.
- `rsyslog_in_image`: Specifies if the target host is a container and use rsyslog in the image. Default to false.
- `rsyslog_purge_original_conf`: By default, the Rsyslog configuration files are applied on top of pre-existing configuration files. To purge local files prior to setting new ones, set `rsyslog_purge_original_conf` variable to 'true', it will move all Rsyslog configuration files to a backup directory before deploying the new configuration files. Defaults to 'false'.
- `rsyslog_system_log_dir`: System log directory.  Default to '/var/log'.
- `rsyslog_work_dir`: Working directory.  Default to '/var/lib/rsyslog'.

Files and Forwards output_role sub-variables
----------------------------------
- `files`: array of dictionary to specify the facility and severity filter and the full path to store logs satisfying the filter.  It takes the sub-variables - `name`, `facility`, `severity`, `exclude`, and `path`.  Unless the name and the path are given, the element is skipped.
Files output format
   ```
   - name: <unique_name>
     type: files
     facility: <facility_in_text, e.g., "mail"; default to "*">
     severity: <severity_in_text, e.g., "info"; default to "*">
     exclude: <excluded facility list separated by ';', e.g., "mail.none;auth.none"; default to nil>
     path: </full/path/to/file/to/store/the/logs; MUST EXIST>
   ```
- `forwards`: array of dictionary to specify the facility and severity filter and the host and port to forward logs satisfying the filter.  It takes the sub-variables - `name`, `facility`, `severity`, `exclude`, `protocol`, `target`, and `port`.  Unless the name and the target are given, the element is skipped.
Forwards output format
   ```
   - name: <unique_name>
     type: forwards
     facility: <facility_in_text, e.g., "mail"; default to "*">
     severity: <severity_in_text, e.g., "info"; default to "*">
     exclude: <excluded facility list separated by ';', e.g., "mail.none;auth.none"; default to nil>
     protocol: <tcp_or_udp; default to "tcp">
     target: <target_host_name_or_ip_address; MUST EXIST>
     port: <port_number; default to 514>
   ```

Files input_role sub-variables
------------------------------
- `rsyslog_input_log_path`: File name to be read by the imfile plugin. The value should be full path. Wildcard '*' is allowed in the path.  Default to `/var/log/containers/*.log`

Viaq input_role sub-variables
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
  - `ca_cert`: Path to CA cert for ElasticSearch.  Default to '/etc/rsyslog.d/es-ca.crt'
  - `cert`: Path to cert for ElasticSearch.  Default to '/etc/rsyslog.d/es-cert.pem'
  - `key`: Path to key for ElasticSearch.  Default to "/etc/rsyslog.d/es-key.pem"
  - `ca_cert_src`: Path to the local CA cert file to deploy for ElasticSearch.
  - `cert_src`: Path to the local cert file to deploy for ElasticSearch.
  - `key_src`: Path to the local key file to deploy for ElasticSearch.

Contents of Roles
=================
It contains the framework and data for the configuration files to be deployed.

The basic framework is based on debops.rsyslog and adjusted to the RHEL/Fedora specification.

- templates have 2 template files, rsyslog.conf.j2 and rules.conf.j2.  The former is used to generate /etc/rsyslog.conf and the latter is for the other configuration files including mmnormalize rulebase and formatter which will be placed in ```{{ rsyslog_config_dir }}``` (default to /etc/rsyslog.d) and its subdirectories.

- tasks/main.yml contains the sceries of tasks to deploy specified set of configuration files.

WARNING: Pre-existing rsyslog.conf and configuration files in /etc/rsyslog.d are moved to the backup directory /tmp/rsyslog.d-XXXXXX.  If the pre-existing files need to be merged with the newly deployed files, you need to do it manually.

-defaults/main.yml defines variables to switch the deployment paths, variables to specify the locations to deploy and the configurations to be deployed.

Describing how the configuration files are defined to be deployed using the viaq case.

Viaq configuration files are defined in {{ __rsyslog_viaq_rules }} in /roles/input_roles/viaq/defaults/main.yml.  The set is made from the generic modules{__rsyslog_conf_global_options, __rsyslog_conf_local_modules, __rsyslog_conf_common_defaults} and viaq specific configurations.

If you are a role developer and planning to add a new default configuration to the role depo, create an rsyslog config item based on the following skelton and add the title {{ __rsyslog_conf_yourname }} to {{ __rsyslog_viaq_rules }}.
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

Some full path configuration may be referred from other configuration file, e.g., 20-viaq_formattiong.conf refers parse_json.rulebase as follows.
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
