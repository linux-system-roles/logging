linux-system-roles Logging (LSR/Logging)
========================================

Guidelines for Using Logging Ansible Role
-----------------------------------------

The `logging` role enables a RHEL admin/developer to deploy logging collectors on the local host, remote host or set of remote hosts,
process these logs if needed to add additional metadata and ship it to a remote location to be saved and analyzed.

The logging role currently supports `Rsyslog` as the log collector.

Table of Contents
=================

<!--ts-->
   * [linux-system-roles Logging](#linux-system-roles-logging)
   * [Table of contents](#table-of-contents)
   * [Definitions](#definitions)
   * [Deploy Default Logging Configuration Files](#deploy-default-logging-configuration-files)
   * [Deploy Configuration Files](#deploy-configuration-files)
      * [Inventory File](#inventory-file)
      * [vars.yml](#varsyml)
      * [Variables in vars.yml](#variables-in-varsyml)
      * [playbook.yml](#playbookyml)
   * [New Projects Integration](#new-projects-integration)
      * [Planned Flows](#planned-flows)
   * [Testing](#testing)
   * [Additional Resources](#additional-resources)
   * [License](#license)
<!--te-->

Definitions
===========

  - [`Rsyslog`](https://www.rsyslog.com/) - The logging role default log collector used for log processing.
  - [`Viaq`](https://docs.okd.io/latest/install_config/aggregate_logging.html)- Common Logging based on OpenShift Aggregated Logging (OCP/Origin).
  - [`Elasticsearch`](https://www.elastic.co/) - Non-OpenShift standalone Elasticsearch.
  - `Local` - Output the collected logs to a local File / Journal (Not yet implemented). Supported only for default and basics Rsyslog data at this point.
  - `Remote Rsyslog` - Output logs to a remote Rsyslog server. - Not yet implemented
  - `Message Queue` (kafka, amqp) - Not yet implemented

Deploy Configuration Files
===========================

Typical ansible-playbook command line includes:

 - vars.yml - containing LSR/Logging variables, which are to be updated by the user.
   The contents of this file could be merged into the inventory file.
 - inventory_file - used to specify the hosts to deploy the configuration files

``` ansible-playbook [-vvv] -e@vars.yml --become --become-user root -i inventory_file playbook.yml ```

Inventory File
--------------

   Sample inventory file
```
[masters]
localhost ansible_user=YOUR_ANSIBLE_USER

[nodes]
localhost ansible_user=YOUR_ANSIBLE_USER
```

vars.yml
---------

vars.yml stores variables which are passed to ansible to control the tasks.

Initial configuration will be supplied by default.
User can supply further configuration to be used.

Currently, the role supports 3 types of logs collections ([input_roles](https://github.com/linux-system-roles/logging/tree/master/roles/rsyslog/roles/input_roles/)): `basics`, `ovirt`, and `viaq`.  And 3 types of log outputs ([output_roles](https://github.com/linux-system-roles/logging/tree/master/roles/rsyslog/roles/output_roles/)): `elasticsearch`, `files`, and `forwards`.  To deploy configuration files with these input and output roles, first specify the output_role as `logging_outputs`, then input_role as `log_collections` in each `logging_outputs`.  Multiple input roles could be required based on the use cases.

To make an effect with the following setting, vars.yml has to have `logging_enabled: true`.  Unless logging_enabled is set to true, LSR/Logging does not deploy logging systems.

**Note:** Current LSR/Logging supports rsyslog only.  In case other logging system is added to LSR/Logging in the future, it's supposed to implement the input and output roles to satisfy the logging_outputs and log_collections semantics.
```
logging_enabled: true
logging_outputs:
  -name: <output_role_name0>
   type: <output_type0>
   log_collections:
     - name: <input_role_nameA>
     - name: <input_role_nameB>
  -name: <output_role_name1>
   type: <output_type1>
   log_collections:
     - name: <input_role_nameC>
```

**vars.yml examples:**

0) Deploying default /etc/rsyslog.conf.
```
logging_enabled: true
```

1) Overriding existing /etc/rsyslog.conf and files in /etc/rsyslog.d with default rsyslog.conf.
```
logging_enabled: true
logging_purge_confs: true
```

2) Deploying basic LSR/Logging config files in /etc/rsyslog.d, which handle inputs from the local system and outputs into the local files.
```
logging_enabled: true
logging_purge_confs: true
logging_outputs:
  - name: local-files
    type: files
    logs_collections:
      - name: system-input
        type: basics
```

3) Deploying basic LSR/Logging config files in /etc/rsyslog.d, which handle inputs from the local system and remote rsyslog and outputs into the local files.
```
logging_enabled: true
rsyslog_capabilities: [ 'network', 'remote-files' ]
logging_purge_confs: true
logging_outputs:
  - name: local-files
    type: files
    logs_collections:
      - name: system-and-remote-input
        type: basics
```

4) Deploying config files for collecting logs from OpenShift pods as well as RHV and forwarding them to elasticsearch.
```
logging_enabled: true
logging_outputs:
  - name: viaq-elasticsearch
    type: elasticsearch
    logs_collections:
      - name: viaq-input
        type: viaq
    # 'state' is not a mandatory field. Defaults to 'present'.
      - name: viaq-k8s-input
        type: viaq-k8s
      - name: ovirt
        type: ovirt-input
        state: absent
    server_host: logging-es
    server_port: 9200
    index_prefix: project.
    ca_cert: <CA_CERT>
    cert: <USER_CERT>
    key: <PRIVATE_KEY>
  - name: ovirt-elasticsearch
    type: elasticsearch
    logs_collections:
      - name: ovirt-input
        type: ovirt
    server_host: logging-es-ovirt
    server_port: 9200
    index_prefix: project.ovirt-logs
    ca_cert: <CA_CERT>
    cert: <USER_CERT>
    key: <PRIVATE_KEY>
  - name: custom_files-test
    type: custom_files
    custom_config_files: [ '/path/to/custom_A.conf', '/path/to/custom_B.conf' ]
```

   See the [variables section](#variables-in-varsyml) for each variable.

**Note:** The order of the record with type `elasticsearch` is important. The last Elasticsearch output will get all the logs that were not cached by previous Elasticsearches instances.

For more details, see also [roles/rsyslog/README.md](https://github.com/linux-system-roles/logging/tree/master/roles/rsyslog/README.md).

Variables in vars.yml
----------------------

- `logging_collector`: The logs collector to use for the logs collection. Currently Rsyslog is the only supported logs collector. Defaults to `rsyslog`.
- `logging_enabled` : When 'true', logging role will deploy specified configuration file set. Default to 'true'.
- `logging_purge_confs`: By default, the Rsyslog configuration files are applied on top of pre-existing configuration files. To purge local files prior to setting new ones, set logging_purge_confs variable to 'true', it will move all Rsyslog configuration files to a backup directory, `/tmp/rsyslog.d-XXXXXX/backup.tgz`, before deploying the new configuration files. Defaults to 'false'.
- `logging_mmk8s_token`: Path to token for kubernetes.  Default to "/etc/rsyslog.d/mmk8s.token".
- `logging_mmk8s_ca_cert`: Path to CA cert for kubernetes.  Default to "/etc/rsyslog.d/mmk8s.ca.crt".

- `logging_outputs`: A set of following variables to specify output configurations.  It could be an list if multiple outputs that should to be configured.
   -  **If `type: elasticsearch`**, send logs to one or more remote elasticsearch or Viaq installations.
      - `name`: Name of the elasticsearch element.
      - `type`: Type of the output element. Optional values: `elasticsearch`, `local`, `custom_files`.
      - `logs_collections` : List of optional logs collections, dictionaries with `name`, `type` and `state` attributes, that were pre-configured.
        - `name`: Unique name of the input.
          `type`: The type of the pre-configured logs to collect. **Note:** Currently ['viaq', 'viaq-k8s', 'ovirt'] are supported for the elasticsearch output.
          
          `state`: The state of the configuration files states if they should be `present` or `absent`. Default to `present`.
      - `server_host`: Hostname elasticsearch is running on.
      - `server_port`: Port number elasticsearch is listening to.
      - `index_prefix`: Elasticsearch index prefix the particular log will be indexed to.
      - `ca_cert`: Path to CA cert for ElasticSearch.  Default to '/etc/rsyslog.d/es-ca.crt'
      - `cert`: Path to cert for ElasticSearch.  Default to '/etc/rsyslog.d/es-cert.pem'
      - `key`: Path to key for ElasticSearch.  Default to "/etc/rsyslog.d/es-key.pem"
   -  **If `type: custom`** To include existing config files in the new ansible deployment, add the paths to custom_config_files as follows.  The specified files are copied to /etc/rsyslog.d.
      - `name`: Name of the custom file output element.
      - `type`: Type of the output element.
      - `custom_config_files`: List of custom configuration files are deployed to /etc/rsyslog.d. [ '/path/to/custom_A.conf', '/path/to/custom_B.conf' ]. Default to none.

playbook.yml
-------------

```
- name: install and configure logging on the nodes
  hosts: nodes
  roles:
    - role: logging
```

New Projects Integration
========================

This role is a generic wrapper for deploying and configuring the log collectors to collect the logs,
format them and ship them to the required destination.
It currently supports Rsyslog as the default logs collector.

The projects are called `logs_collections` and the user can choose to deploy several projects at the same time.
Each project adds a sub-role to [input_roles](https://github.com/linux-system-roles/logging/tree/master/roles/rsyslog/roles/input_roles/).

The sub-role usually includes `tasks` and `defaults` directories.
The `defaults` directory includes:
  - List of required packages that are **not** the base rsyslog_base_packages: ['rsyslog']
  - List of modules to load  like `imfile`, `imtcp`, etc.
  - Defines the formatting and the rulebases for parsing the logs.
  - It is required to set for all logs the project identfier for pipelining:
    set $.logs_collection = "project name";

The `tasks` directory includes 2 tasks file:
  - `main.yml` - tasks for deploying the config files
    This file is sets `__rsyslog_packages` and `__rsyslog_rules` and includes the task that deploys the files.
  - `cleanup.yml` - tasks that cleanup the files deployed for this project.

Examples can be found in the existing projects.

The available outputs are defined in [output_roles](https://github.com/linux-system-roles/logging/tree/master/roles/rsyslog/roles/output_roles/).
Currently, It supports Elasticsearch, writing to local files, and forwarding to remote rsyslog.
Additional output will be added.

Planned Flows:
--------------
  - `Rsyslog` -> `Local` (RHEL Default) / `Viaq` [1] / `Elasticsearch` / `Remote Rsyslog` / `message Queue (kafka, amqp)`

[1] Rsyslog to Viaq currently means doing output to the OCP Elasticsearch using client cert auth.
    In the future we want to support Rsyslog to OCP rsyslog using RELP, or Rsyslog to mux using fluent relp input plugin, or message queue.

Testing
=======
In-tree tests are provided that use molecule to test the role against docker containers.
These tests are designed to be used by CI, but they can also be run locally to test it
out while developing.  This is best done by installing molecule in a virtualenv:

```
$ virtualenv .venv
$ source .venv/bin/activate
$ pip install 'molecule<3' docker
```

It is required to run the tests as a user who is authorized to run the 'docker' command
without using sudo.  This is typically accomplished by adding your user to the 'docker'
group on your system.

Additionally, there is a challenge around python-libselinux (python3-libselinux for python3) on platforms that use SELinux.
If you are using a virtualenv, you need to make sure that the selinux python module is
available in the virtualenv.  Even if it is installed on your ansible controller host
and the target host, some of the tasks that are delegated to the locahost will use the
virtualenv.  The selinux module can't be installed via pip.  A workaround for this is
to copy the entire `selinux` directory from your system site-packages location into
the virtualenv site-packages.  You also need to copy the `_selinux.so` file from
site-locations as well.

Once your virtualenv is properly set up, the tests can be run with these commands:

  `$ molecule test`

By default, the test target will be the latest `centos` image from Docker Hub.  You
can test against a different image/tag like so:

  `$ MOLECULE_DISTRO="fedora:30" molecule test`

Additional Resources
====================

Additional Rsyslog custom parameters can be added to the logging role vars.yml file,
based on the parameters in the [Rsyslog role README file](https://github.com/linux-system-roles/logging/tree/master/roles/rsyslog/roles/README.md).

License
=======

Apache License 2.0

