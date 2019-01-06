linux-system-roles Logging
==========================

Guidelines for Using Logging Ansible Role
-----------------------------------------

The `logging` role enables a RHEL admin/developer to deploy logging collectors on the local host, remote host or set of remote hosts,
process these logs if needed to add additional metadata and ship it to a remote location to be saved and analyzed.

The logging role currently supports `Rsyslog` as the log collector.

Definitions
-----------

  - [`Rsyslog`](https://www.rsyslog.com/) - The logging role default log collector used for log processing.
  - [`Viaq`](https://docs.okd.io/latest/install_config/aggregate_logging.html)- Common Logging based on OpenShift Aggregated Logging (OCP/Origin).
  - [`Elasticsearch`](https://www.elastic.co/) - Non-OpenShift standalone Elasticsearch.
  - `Local` - Output the collected logs to a local File/Journal. Supported only for default and debops Rsyslog data at this point.
  - `Remote Rsyslog` - Output logs to a remote Rsyslog server. - Not yet implemented
  - `Message Queue` (kafka, amqp) - Not yet implemented

Deploy Default Logging Configuration Files
==========================================


``` ansible-playbook [-vvv]  --become --become-user root --connection local -i inventory_file playbook.yaml ```


Deploy Configuration Files
===========================

Typical ansible-playbook command line.

``` ansible-playbook [-vvv] -e@vars.yaml --become --become-user root --connection local -i inventory_file playbook.yaml ```

Two files - inventory_file and vars.yaml - in the command line is to be updated by the user.

Inventory File
--------------
inventory_file is used to specify the hosts to deploy the configuration files.

   Sample inventory file for the es-ops enabled case
```
[masters]
localhost ansible_user=YOUR_ANSIBLE_USER

[nodes]
localhost ansible_user=YOUR_ANSIBLE_USER
```

Deploy Default Logging Configuration Files
------------------------------------------

For default logging configuration files, add the inventory_file and run the ansible playbook without the vars.yaml file.

``` ansible-playbook [-vvv]  --become --become-user root --connection local -i inventory_file playbook.yaml ```

No additional steps required.

vars.yaml
---------

vars.yaml stores variables which are passed to ansible to control the tasks.

**Note:**   Currently, the role supports 3 types of logs collections: default, 'viaq' and 'debops'. 'viaq' and 'debops' can theoretically, both be added to the logs_collections and the specified configuration files are deployed, but rsyslog does not work properly with the configuration.

Initial conf will be supplied by default.
User can supply another conf to be used.

Configure the list of outputs you want to send your logs to.


vars.yaml example:

```
If 'viaq-k8s' is in logs_collections, logging_mmk8s_* need to be specified.
logging_mmk8s_token:
logging_mmk8s_ca_cert:

logging_outputs:
  - name: viaq-elasticsearch
    type: elasticsearch
    logs_collections:
      - name: 'viaq'
    # 'state' is not a mandatory field. Defaults to 'present'.
      - name: 'viaq-k8s'
      - name: 'ovirt'
        state: 'absent'
    server_host: logging-es
    server_port: 9200
    index_prefix: project.
    ca_cert:
    cert:
    key:
  - name: ovirt-elasticsearch
    type: elasticsearch
    logs_collections:
      - name: 'ovirt'
    server_host: logging-es-ovirt
    server_port: 9200
    index_prefix: project.ovirt-logs
    ca_cert:
    cert:
    key:
  - name: custom_files-test
    type: custom_files
    custom_config_files: [ '/path/to/custom_A.conf', '/path/to/custom_B.conf' ]
```

   See the variables section for each variable.

**Note:** The order of the record with type  `elasticsearch` is important. The last Elasticsearch output will get all the logs that were not cached by previous Elasticsearches instances.

playbook.yaml
-------------

- name: install and configure logging on the nodes
  hosts: nodes
  roles:
    - role: logging


Variables in vars.yaml
======================

- `logging_collector`: The logs collector to use for the logs collection. Currently Rsyslog is the only supported logs collector. Defaults to `rsyslog`.
- `logging_enabled` : When 'True' logging role will deploy specified configuration file set. Default to 'True'.
- `logging_purge_confs`: By default, the Rsyslog configuration files are applied on top of pre-existing configuration files. To purge local files prior to setting new ones, set logging_purge_confs variable to 'True', it will move all Rsyslog configuration files to a backup directory, `/tmp/rsyslog.d-XXXXXX/backup.tgz`, before deploying the new configuration files. Defaults to 'False'.
- `logging_mmk8s_token`: Path to token for kubernetes.  Default to "/etc/rsyslog.d/viaq/mmk8s.token".
- `logging_mmk8s_ca_cert`: Path to CA cert for kubernetes.  Default to "/etc/rsyslog.d/viaq/mmk8s.ca.crt".

- `logging_outputs`: A set of following variables to specify output configurations.  It could be an list if multiple outputs that should to be configured.
   -  **If `type: elasticsearch`** Send logs to one or more remote elasticsearch or Viaq installations.
      - `name`: Name of the elasticsearch element.
      - `type`: Type of the output element. Optional values: `elasticsearch`, `local`, `custom_files`.
      - `logs_collections` : List of optional logs collections, dictionaries with `name` and `state` attributes, that were pre-configured.
        - `name`: The name of the pre-configured logs to collect. **Note:** Currently only ['viaq', 'viaq-k8s', 'ovirt'] are supported for the elasticsearch output.
          `state`: The state of the configuration files states if they should be `present` or `absent`. Default to `present`.
      - `server_host`: Hostname elasticsearch is running on.
      - `server_port`: Port number elasticsearch is listening to.
      - `index_prefix`: Elasticsearch index prefix the particular log will be indexed to.
      - `ca_cert`: Path to CA cert for ElasticSearch.  Default to '/etc/rsyslog.d/elasticsearch/es-ca.crt'
      - `cert`: Path to cert for ElasticSearch.  Default to '/etc/rsyslog.d/elasticsearch/es-cert.pem'
      - `key`: Path to key for ElasticSearch.  Default to "/etc/rsyslog.d/elasticsearch/es-key.pem"
   -  **If `type: custom`** To include existing config files in the new ansible deployment, add the paths to custom_config_files as follows.  The specified files are copied to /etc/rsyslog.d.
      - `name`: Name of the custom file output element.
      - `type`: Type of the output element.
      - `custom_config_files`: List of custom configuration files are deployed to /etc/rsyslog.d. [ '/path/to/custom_A.conf', '/path/to/custom_B.conf' ]. Default to none.

Planned Flows:
--------------
  - `Rsyslog` -> `Local` (RHEL Default) / `Viaq` [1] / `Elasticsearch` / `Remote Rsyslog` / `message Queue (kafka, amqp)`

[1] Rsyslog to Viaq currently means doing output to the OCP Elasticsearch using client cert auth.
    In the future we want to support Rsyslog to OCP rsyslog using RELP, or Rsyslog to mux using fluent relp input plugin, or message queue.

Additional Resources
--------------------

Additional Rsyslog custom parameters can be added to the logging role vars.yaml file,
based on the parameters in the Rsyslog role README file under the /roles directory.



License
-------

Apache License 2.0

