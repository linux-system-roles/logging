linux-system-roles-rsyslog/roles
======================================

# Guidelines for Using Rsyslog Input and Output Roles

The input roles include Rsyslog configurations, for different projects, that user can collectd logs on.

The projects are called `logging_inputs` and the user can choose to deploy several projects at the same time.
Each project adds a sub-role to ./logging/roles/rsyslog/roles/input_roles/.

The sub-role usually includes `tasks` and `defaults` directories.
The `defaults` directory includes:
  - List of required packages that are **not** the base rsyslog_base_packages: ['rsyslog']
  - List of modules to load  like `imfile`, `imtcp`, etc.
  - Defines the formatting and the rulebases for parsing the logs.
  - It is required to set for all logs the project identfier for pipelining:
    set $.input_type = "input type";
    For example: In `ovirt` input role, in the default/main.yml, for every log `$.input_type` is set to `ovirt`.
  - If `rsyslog_default` equals to "true", It is required to set for all logs you don't want to be processed by the default rules:
    set $.send_targets_only = "true";

The `tasks` directory includes 2 task files:
  - `main.yml` - tasks for deploying the config files
    This file sets `__rsyslog_packages` and `__rsyslog_rules` and includes the task that deploys the files.
  - `cleanup.yml` - tasks that cleanup the files deployed for this project.

Examples can be found in the existing projects.

The available outputs are defined in /logging/roles/rsyslog/roles/output_roles/.
Currently, It supports Elasticsearch output.
Additional output will be added.

Planned Flows:
--------------
  - `Rsyslog` -> `Local` (RHEL Default) / `Viaq` [1] / `Elasticsearch` / `Remote Rsyslog` / `message Queue (kafka, amqp)`

[1] Rsyslog to Viaq currently means doing output to the OCP Elasticsearch using client cert auth.
    In the future we want to support Rsyslog to OCP rsyslog using RELP, or Rsyslog to mux using fluent relp input plugin, or message queue.

