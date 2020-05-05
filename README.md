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
  - `Remote Rsyslog` - Input logs from or output logs to a remote Rsyslog server.
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

Currently, the logging role supports 5 types of logging inputs ([inputs](https://github.com/linux-system-roles/logging/tree/master/roles/rsyslog/tasks/inputs/)): `basics`, `files`, `ovirt`, `remote`, and `viaq`.  And 4 types of outputs ([outputs](https://github.com/linux-system-roles/logging/tree/master/roles/rsyslog/tasks/outputs/)): `elasticsearch`, `files`, `forwards`, and `remote_files`.  To deploy configuration files with these inputs and outputs, specify the inputs as `logging_inputs` and the outputs as `logging_outputs`. For definining the flow from inputs to outputs, use `logging_flows`.  The `logging_flows` has 3 sub variables `name`, `inputs`, and `outputs`, where `inputs` is a list of `logging_inputs name` values and `outputs` is a list of `logging_outputs name` values.

To make an effect with the following setting, vars.yml has to have `logging_enabled: true`.  Unless logging_enabled is set to true, LSR/Logging does not deploy logging systems.

**Note:** Current LSR/Logging supports rsyslog only.  In case other logging system is added to LSR/Logging in the future, it's supposed to implement the input and output tasks to satisfy the logging_outputs and logging_inputs semantics.

This is an example of the logging configuration to show log messages from input_nameA are passed to output_name0 and output_name1; log messages from input_nameB are to output_name1, only.
```
logging_enabled: true
logging_outputs:
  - name: output_name0
    type: output_type0
  - name: output_name1
    type: output_type1
logging_inputs:
  - name: input_nameA
    type: input_typeA
  - name: input_nameB
    type: input_typeB
logging_flows:
  - name: flow_nameX
    inputs: [input_nameA]
    outputs: [output_name0, output_name1]
  - name: flow_nameY
    inputs: [input_nameB]
    outputs: [output_name1]
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

2) Deploying basic LSR/Logging config files in /etc/rsyslog.d, which handle inputs from the local system (e.g. systemd journald), and outputs into local files (e.g. /var/log/messages).
```
logging_enabled: true
logging_purge_confs: true
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

3) Deploying basic LSR/Logging config files in /etc/rsyslog.d, which handle inputs from the remote rsyslog and outputs into the local files per host.
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

4) Deploying config files for collecting logs from OpenShift pods as well as RHV and forwarding them to elasticsearch.
```
logging_enabled: true
logging_outputs:
  - name: viaq-elasticsearch
    type: elasticsearch
    server_host: logging-es
    server_port: 9200
    index_prefix: project.
    ca_cert: <CA_CERT>
    cert: <USER_CERT>
    key: <PRIVATE_KEY>
  - name: ovirt-elasticsearch
    type: elasticsearch
    server_host: logging-es-ovirt
    server_port: 9200
    index_prefix: project.ovirt-logs
    ca_cert: <CA_CERT>
    cert: <USER_CERT>
    key: <PRIVATE_KEY>
  - name: files-output
    type: files
  - name: custom_files-test
    type: custom_files
    custom_config_files: [ '/path/to/custom_A.conf', '/path/to/custom_B.conf' ]
logging_inputs:
  - name: viaq-input
    type: viaq
  - name: viaq-k8s-input
    type: viaq-k8s
  - name: ovirt
    type: ovirt-input
logging_flows:
  - name: flow0
    inputs: [viaq-input, viaq-k8s-input]
    outputs: [viaq-elasticsearch]
  - name: flow1
    inputs: [ovirt-input]
    outputs: [ovirt-elasticsearch, files-output]
```
In this example, viaq-input and viaq-k8s-input are passed to viaq-elasticsearch; ovirt-input is passed to the ovirt-elasticsearch as well as files-output.

See the [variables section](#variables-in-varsyml) for each variable.

For more details, see also [roles/rsyslog/README.md](https://github.com/linux-system-roles/logging/tree/master/roles/rsyslog/README.md).

Variables in vars.yml
----------------------

- `logging_enabled` : When 'true', logging role will deploy specified configuration file set. Default to 'true'.
- `logging_mmk8s_token`: Path to token for kubernetes.  Default to "/etc/rsyslog.d/mmk8s.token".
- `logging_mmk8s_ca_cert`: Path to CA cert for kubernetes.  Default to "/etc/rsyslog.d/mmk8s.ca.crt".
- `logging_outputs`: A set of following variables to specify output configurations.  It could be an list if multiple outputs that should to be configured.
   - `name`: Unique name of the output
   - `type`: Type of the output element. Currently, `elasticsearch`, `files`, `forwards`, and `remote_files` are supported. The `type` is used to specify a task type which corresponds to a directory name in roles/rsyslog/{tasks,vars}/outputs/.
   -  ** `type: elasticsearch`**
      - `server_host`: Hostname elasticsearch is running on.
      - `server_port`: Port number elasticsearch is listening to.
      - `index_prefix`: Elasticsearch index prefix the particular log will be indexed to.
      - `input_type`: Specifying the input type. Type `ovirt` and `viaq` are supported. Default to `ovirt`.
      - `retryfailures`: Specifying whether retries or not in case of failure. on or off.  Default to on.
      - `ca_cert`: Path to CA cert for ElasticSearch.  Default to '/etc/rsyslog.d/es-ca.crt'
      - `cert`: Path to cert for ElasticSearch.  Default to '/etc/rsyslog.d/es-cert.pem'
      - `key`: Path to key for ElasticSearch.  Default to "/etc/rsyslog.d/es-key.pem"
   -  ** `type: files`**
      - `facility`: facility; default to `*`
      - `severity`: severity; default to `*`
      - `exclude`: exclude list; default to none.
      - `path`: path to the output file.  Must have.  If `path` is not defined, the files instance is dropped.
      These values are used in the omfile action as follows:
      ```
      facility.severity;<semicolon separated exclude list> path
      ```
   -  ** `type: forwards`**
      - `facility`: facility; default to `*`
      - `severity`: severity; default to `*`
      - `protocol`: protocol; tcp or udp; default to tcp.
      - `target`: target host (fqdn).  Must have.  If `target` is not defined, the forwards instance is dropped.
      - `port`: port; default to 514.
   -  **If `type: custom`** To include existing config files in the new ansible deployment, add the paths to custom_config_files as follows.  The specified files are copied to /etc/rsyslog.d.
      - `name`: Name of the custom file output element.
      - `type`: Type of the output element.
      - `custom_config_files`: List of custom configuration files are deployed to /etc/rsyslog.d. [ '/path/to/custom_A.conf', '/path/to/custom_B.conf' ]. Default to none.
   -  ** `type: remote_files`**
      - `facility`: facility; default to `*`
      - `severity`: severity; default to `*`
      - `exclude`: exclude list; default to none.
      - `remote_log_path`: full path to store the filtered logs.
      - `remote_sub_path`: relative path to logging_system_log_dir to store the filtered logs.
	                       if `remote_log_path` nor `remote_sub_path` are not specified, the remote_file output configured with the default settings.
- `logging_inputs` : List of optional logs collections, dictionaries with `name`, `type` and `state` attributes, that were pre-configured.
        - `name`: Unique name of the input.
          `type`: The type of the log inputs. **Note:** Currently [`basics`, `files`, `ovirt`, `remote`, and `viaq`] are supported.
          `state`: The state of the configuration files states if they should be `present` or `absent`. Default to `present`.
   -  ** `type: basics`**
      - `rsyslog_imjournal_ratelimit_burst`: set to imjournal RateLimit.Burst. Default to 20000.
      - `rsyslog_imjournal_ratelimit_interval`: set to imjournal RateLimit.Interval. Default to 600.
      - `rsyslog_imjournal_persist_state_interval`: set to imjournal PersistStateInterval. Default to 10.
   -  ** `type: files`**
      - `rsyslog_input_log_path`: File name to be read by the imfile plugin. The value should be full path. Wildcard '*' is allowed in the path.  Default to `/var/log/containers/*.log`.
   -  ** `type: remote_files`**
      - `udp_port`: if the port number is given, rsyslog is configured to listen at the udp port number. Default to 514.
      - `tcp_port`: if the port number is given, rsyslog is configured to listen at the tcp port number. Default to 514.
      - `tcp_tls_port`: if the port number is given, rsyslog is configured to listen at the tls tcp port number. Default to 6514.

- `logging_provider`: The logging collector to use for the logging provider. Currently Rsyslog is the only supported logging provider. Defaults to `rsyslog`.
- `logging_purge_confs`: By default, the Rsyslog configuration files are applied on top of pre-existing configuration files. To purge local files prior to setting new ones, set logging_purge_confs variable to 'true', it will move all Rsyslog configuration files to a backup directory, `/tmp/rsyslog.d-XXXXXX/backup.tgz`, before deploying the new configuration files. Defaults to 'false'.
- `logging_system_log_dir`: System log directory.  Default to '/var/log'.

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

The projects are called `logging_inputs` and the user can choose to deploy several projects at the same time.
Each project adds a sub-task to [inputs](https://github.com/linux-system-roles/logging/tree/master/roles/rsyslog/tasks/inputs/) with the matching var file in [inputs](https://github.com/linux-system-roles/logging/tree/master/roles/rsyslog/vars/inputs/).

The sub-task/main.yml in [inputs](https://github.com/linux-system-roles/logging/tree/master/roles/rsyslog/vars/inputs/) usually contains.
  - List of required packages that are **not** the base rsyslog_base_packages: ['rsyslog']
  - List of modules to load  like `imfile`, `imtcp`, etc.
  - Defines the formatting and the rulebases for parsing the logs.
  - It is required to set for all logs the project identifier for pipelining:
    set $.input_type = "input type";

The `tasks/sub-task` directory includes 2 tasks file:
  - `main.yml` - tasks for deploying the config files
    This file is sets `__rsyslog_packages` and `__rsyslog_rules` and includes the task that deploys the files.

Examples can be found in the existing projects.

The available outputs are defined in [outputs](https://github.com/linux-system-roles/logging/tree/master/roles/rsyslog/tasks/outputs/).
Currently, It supports Elasticsearch, writing to local files, and forwarding to remote rsyslog.
Additional output will be added.

Planned Flows:
--------------
  - `Rsyslog` -> `Local` (RHEL Default) / `Viaq` [1] / `message Queue (kafka, amqp)`

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

CI tests
========
The tests are tests/tests_*.yml, which are triggered when a pull request is submitted.  Each tests_testname.yml is written in the ansible format. The file is made from the test logging_outputs, logging_inputs and logging_flows configuration, ansible execution, and the test result checking.

It is triggered when a pull request is submitted and its commit is updated.

To run the tests manually,
1. Download CentOS qcow2 image from https://cloud.centos.org/centos/.
2. Run the following command from the `tests` directory, which spawns an openshift node locally and runs the test yml on it.
   ```
   TEST_SUBJECTS=/path/to/downloaded_your_CentOS_7_or_8_image.qcow2 ansible-playbook [-vvvv] -i /usr/share/ansible/inventory/standard-inventory-qcow2 tests_testname.yml
   ```
3. To debug it, add `TEST_DEBUG=true` prior to `ansible-playbook`.
4. Once the ansible-playbook is finished, you could ssh to the node as follows:
   ```
   ssh -p PID -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /tmp/inventory-cloudRANDOMSTR/identity root@127.0.0.3
   ```
   The PID is returned from the following command line.
   ```
   ps -ef | grep "linux-system-roles.logging.tests" | egrep -v grep | awk '{print $28}' | awk -F':' '{print $3}' | awk -F'-' '{print $1}'
   ```
5. When the debugging is done, run `ps -ef | grep standard-inventory-qcow2` and kill the pid to clean up the node.

For more details, see also https://github.com/linux-system-roles/test-harness.

Additional Resources
====================

Additional Rsyslog custom parameters can be added to the logging role vars.yml file,
based on the parameters in the [Rsyslog role README file](https://github.com/linux-system-roles/logging/tree/master/roles/rsyslog/roles/README.md).

License
=======

Apache License 2.0

