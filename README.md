Logging
====================

The `logging` role enables you to deploy required log collectors, logs parsing and adding additional metadata, and shipping them
to the desired location.

For logs collection and processing you can either:
-  Select logs from the optional supported logs.
-  Add configuration files to `/etc/rsyslog.d/` for Rsyslog
-  Add configuration files to `/etc/fluentd/config.d/` for Fluentd


The default setup is Rsyslog logs collector saved to local machine.


Role Variables
--------------

### Configure logging

In order to run this role you may want to update the following variables:

- `logging_collector:`  (default: `"rsyslog"`)

   The supported logging collectors that can be used.
   Valid options are:
   `"rsyslog"`, `"fluentd"`.

- `rsyslog_output_plugin:`  (default: `"local"`)

   The output plugin that will be used.
   Valid options are `"local"` to send the logs to local machine (RHEL Default),
   `"elasticsearch"` to send the logs to a remote elasticsearch server,
   `"rsyslog"` to send the logs to a remote central rsyslog,
   `"ampq"` to send the logs to a remote AMQP instance,
   `"kafka"` to send the logs to a remote Kafka instance.

- `fluentd_output_plugin:`  (default: `"elasticsearch"`)

   The output plugin that will be used.
   Valid options are `"file"` to send the logs to a local file (Use only for debugging),
   `"elasticsearch"` to send the logs to a remote elasticsearch server,
   `"fluentd"` to send the logs to a remote central fluentd aggregator (mux).

For target outputs other then `local` and `file` additional parameters are required.

Please see the `rsyslog-outputs` or `fluentd-outputs` role README files for additional information.


### Optional logs to collect

- `collect_ovirt_vdsm_log:`(default: `"false"`)
  Set this parameter to `true` if you wish to collect the oVirt vdsm.log.

- `collect_ovirt_engine_log:`(default: `"false"`)
  Set this parameter to `true` if you wish to collect the oVirt engine.log.

# Deploying the Logging Role

For deploying default logging simply run:

    ansible-playbook ${PATH_TO_LINUX_SYSTEM_ROLES}/logging/playbooks/configure-logging.yml

# Example

For example, deploying logging for `oVirt host` - Collects VDSM.log using `Fluentd` and ships them to `Elasticsearch` (OpenShift Logging)

    ansible-playbook -i ${PATH_TO_LINUX_SYSTEM_ROLES}/logging/examples/ovirt-host ${PATH_TO_LINUX_SYSTEM_ROLES}/logging/playbooks/configure-logging.yml

License
-------

Apache License 2.0

