# Guidelines for Using Logging Ansible Roles

The `logging` role allowa a RHEL admin/developer to deploy logging collectors on the local host, remote host or set of remote hosts,
process these logs if needed to add additional metadata and ship it to a remote location to be saved and analyzed.

The logging role currently supports 2 log collectors. `Rsyslog` and `Fluentd`.

## Definitions

  - [`Rsyslog`](https://www.rsyslog.com/) - The logging role default log collector used for log processing.
  - [`Fluentd`](https://www.fluentd.org/) - log collector used for log processing.
  - [`Viaq`](https://docs.okd.io/latest/install_config/aggregate_logging.html)- Common Logging based on OpenShift Aggregated Logging (OCP/Origin)
  - [`Elasticsearch`](https://www.elastic.co/) - Non-OpenShift standalone Elasticsearch.
  - `Local` - Output the collected logs to a local file.
  - `Remote Rsyslog` - Output logs to a remote Rsyslog server.
  - `Fluentd Forward` - Output logs to a remote Fluentd server.

## Supported flows:

  - `Rsyslog` -> `Local` (RHEL Default) / `Viaq` [1] / `Elasticsearch` / `Remote Rsyslog`
  - `Fluentd` -> `Local` (File) / Viaq / `Viaq` [1] / `Elasticsearch` / `Fluentd Forward`

[1] Rsyslog to Viaq currently means doing output to the OCP Elasticsearch using client cert auth.
    In the future we want to support Rsyslog to OCP rsyslog using RELP, or Rsyslog to mux using fluent relp input plugin, or message queue.

## Supported log collectors, Processors and Outputs:


### Collectors

    Initial conf will be supplied by default.
    User can supply another conf to be used.

    Collectors are used for data collection, processing, enrichment and shipping.

Collectors list:
  - `Fluentd`
  - `Rsyslog`

### Outputs

   The user will configure what is the required output and output conf will be configured accordingly.

Output list:
  - Viaq
  - Local (File/Journal)
  - Elasticsearch
  - Fluentd Forward
  - Remote Rsyslog - Not yet supported
  - Message Queue (kafka, amqp) - Not yet supported.

Low level output list:

  These are the mechanisms by which the items in the output list will be implemented.
  For example, output to Viaq currently is implemented by using Fluentd Elasticsearch output with client cert auth, or secure_forward to mux(Fluentd Aggregator).

  - syslog - rfc5424 wire protocol - used by rsyslog imfwd/omfwd, fluentd remote-syslog.
  - secure_forward - fluentd only, currently.
  - RELP - rsyslog only, although there is an fluentd RELP input plugin that is under development.
  - Elasticsearch - http rest api.
  - kafka
  - amqp

## How to use

   * [User Guide](https://github.com/linux-system-roles/logging/docs/README.md)

## Additional Resources


   * [Rsyslog vars.yaml examples](https://github.com/linux-system-roles/logging/docs/vars_yaml_rsyslog.md)
   * [Fluentd vars.yaml examples](https://github.com/linux-system-roles/logging/docs/vars_yaml_fluentd.md)

License
-------

Apache License 2.0

