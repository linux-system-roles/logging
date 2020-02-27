# Current logging subsystem structure

It is designed to satisfy following requirements.

- Adding more logging systems such as fluentd, grafana loki, etc.
- Supporting flexible combinations of input_role and output_role such as input from files and/or journald and output to files and/or elasticsearch.
- More inputs and outputs could be added.
- The existing scenario, especially input_role ovirt + output_role elasticsearch should not be affected by the other roles.

```
linux-system-roles
|
|- logging
   |
   |- meta
   |- molecule: tests using molecule
   |- tasks: common tasks
   |- tests: tests using test-harness
   |- roles
      |
      |- rsyslog
         |
         |- defaults
         |- handlers
         |- tasks
         |- templates: template for the default rsyslog.conf and config files to generate in rsyslog.d
         |- roles
            |
            |- input_roles
            |  |
            |  |- basics: reads logs from systemd-journald or unix socket or input tcp/udp
            |  |  |
            |  |  |- tasks
            |  |  |- defaults
            |  |
            |  |- ovirt: reads logs from ovirt and processes the logs to send them to elasticsearch)
            |  |  |
            |  |  |- tasks
            |  |  |- defaults
            |  |
            |  |- viaq: reads logs from systemd-journald and processes the logs to send them to elasticsearch
            |  |  |
            |  |  |- tasks
            |  |  |- defaults
            |  |
            |  |- viaq-k8s: reads log files from k8s and processes the logs to send them to elasticsearch
            |     |
            |     |- tasks
            |     |- defaults
            |
            |- output_roles
               |
               |- files: writes logs to local files
               |  |
               |  |- tasks
               |  |- defaults
               |
               |- forwards: forwards logs to remote hosts
               |  |
               |  |- tasks
               |  |- defaults
               |
               |- elasticsearch: sends logs to elasticsearch
                  |
                  |- tasks
                  |- defaults
```

# How Logging role starts

When ansible-playbook is executed with a playbook pointing to the logging role,
it starts with tasks in logging/tasks/main.yml.
In the tasks, it evaluates the `logging_outputs`, `logging_inputs` parameters in the loop
to pass the dictionaries to each subsystem.
The following is a format of the outputs/inputs/flows parameters for the `files` and `forwards` output.

## basics inputs/files outputs/flows
```
logging_outputs: [1]
  - name: unique_output_name
    type: files [2]
    severity: severity [5]
    facility: facility [6]
    exclude: exclude_string [7]
    path: fullpath [8]
  - name: unique_output_name
        .................
logging_inputs: [3]
  - name: unique_input_name
    type: input_type [4]
  - name: unique_input_name
        .................
logging_flows: [9]
  - name: unique_flow_name
    inputs: [ input_name(s) ] [10]
    outputs: [ output_name(s) ] [11]
  - name: unique_flow_name
        .................
```

## basics inputs/forwards outputs/flows
```
logging_outputs: [1]
  - name: unique_output_name
    type: forwards [2]
    severity: severity [5]
    facility: facility [6]
    exclude: exclude_string [7]
    protocol: protocol [12]
    target: target_host [13]
    port: port_number [14]
  - name: unique_output_name
        .................
logging_inputs: [3]
  - name: unique_input_name
    type: input_type [4]
        .................
logging_flows: [9]
  - name: unique_flow_name
    inputs: [ input_name(s) ] [10]
    outputs: [ output_name(s) ] [11]
  - name: unique_flow_name
        .................
```
[1]: logging_outputs are implemented in ./logging/roles/rsyslog/roles/output_roles/.<br>
[2]: output type is one of [elasticsearch, files, forwards]; the type matches the directory name in output_roles.<br>
[3]: logging_inputs are implemented in ./logging/roles/rsyslog/roles/input_roles/.<br>
[4]: input_type is one of [basics, ovirt, viaq, viaq-k8s]; the type matches the directory name in input_roles.<br>
[5]: severity: logs higher than or equal to the value match; e.g., info.  Default to `*`.<br>
[6]: facility: e.g., auth,authpriv,mail. Default to `*`.<br>
[7]: exclude: string to be added as facility.severity;exclude in the filter. The format is facility0.none,facility1.none,...  E.g., authpriv.none;auth.none;cron.none;mail.none.  Default to none.<br>
[8]: fullpath to store logs.<br>
[9]: logging_flows are used in the input roles (input_roles/{basics,files,etc.}) to set the `call output_ruleset`.
[10]: inputs contains the list of unique_input_name(s).
[11]: outputs contains the list of unique_output_name(s).
[12]: tcp or udp.  Default to tcp.<br>
[13]: fqdn or IP address of the target host.<br>
[14]: port number.  Default to 514<br>
