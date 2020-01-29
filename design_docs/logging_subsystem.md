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
it starts with tasks in logging/tasks/main.yaml.
In the tasks, it evaluates the `logging_outputs`, `logs_collections` parameters in the loop
to pass the dictionaries to each subsystem.
If the `logging_output` is `files`, `rsyslog_files_actions` is evaluated.
If the `logging_putput` is `forwards`, `rsyslog_forwards_action` is evaluated.
The following is a format of the outputs/inputs/action parameters for the `files` and `forwards` output.

## input/files output/action
```
logging_outputs: [1]
  - name: unique_output_name
    type: files [2]
    logs_collections: [3]
      - name: unique_input_name
        type: input_type [4]
    rsyslog_files_actions:
      - name: unique_name
        severity: severity [5]
        facility: facility [6]
        exclude: exclude_string [7]
        path: fullpath [8]
      - name: unique_name
        .................
```

## input/forwards output/action
```
logging_outputs: [1]
  - name: unique_output_name
    type: forwards [2]
    logs_collections: [3]
      - name: unique_input_name
        type: input_type [4]
    rsyslog_forwards_actions:
      - name: unique_name
        severity: severity [5]
        facility: facility [6]
        exclude: exclude_string [7]
        protocol: protocol [9]
        target: target_host [10]
        port: port_number [11]
      - name: unique_name
        .................
```
[1]: logging_outputs are implemented in ./logging/roles/rsyslog/roles/output_roles/.<br>
[2]: output type is one of [elasticsearch, files, forwards]; the type matches the directory name in output_roles.<br>
[3]: logs_collections are implemented in ./logging/roles/rsyslog/roles/input_roles/.<br>
[4]: input_type is one of [basics, ovirt, viaq, viaq-k8s]; the type matches the directory name in input_roles.<br>
[5]: severity: logs higher than or equal to the value match; e.g., info.  Default to `*`.<br>
[6]: facility: e.g., auth,authpriv,mail. Default to `*`.<br>
[7]: exclude: string to be added as facility.severity;exclude in the filter. The format is facility0.none,facility1.none,...  E.g., authpriv.none;auth.none;cron.none;mail.none.  Default to none.<br>
[8]: fullpath to store logs.<br>
[9]: tcp or udp.  Default to tcp.<br>
[10]: fqdn or IP address of the target host.<br>
[11]: port number.  Default to 514<br>
