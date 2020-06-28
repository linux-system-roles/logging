# Current logging subsystem structure

It is designed to satisfy following requirements.

- Adding more logging systems such as fluentd, grafana loki, etc.
- Supporting flexible combinations of tasks in inputs and outputs such as input from files and/or journald and output to files and/or elasticsearch.
- More inputs and outputs will be added.
- The existing scenario, especially an input ovirt + output elasticsearch should not be affected by the updates.

```
logging/
├── defaults
│   └── main.yml
├── meta
│   └── main.yml
├── molecule
│   └── default
│       ├── Dockerfile.j2
│       ├── INSTALL.rst
│       ├── molecule.yml
│       ├── playbook.yml
│       ├── tests
│       │   └── test_default.py
│       └── yaml-lint.yml
├── roles
│   └── rsyslog
│       ├── defaults
│       │   └── main.yml
│       ├── handlers
│       │   └── main.yml
│       ├── tasks
│       │   ├── deploy.yml
│       │   ├── inputs
│       │   │   ├── basics
│       │   │   │   └── main.yml
│       │   │   ├── files
│       │   │   │   └── main.yml
│       │   │   ├── ovirt
│       │   │   │   └── main.yml
│       │   │   └── remote
│       │   │       ├── cleanup.yml
│       │   │       └── main.yml
│       │   ├── main.yml
│       │   └── outputs
│       │       ├── elasticsearch
│       │       │   └── main.yml
│       │       ├── files
│       │       │   └── main.yml
│       │       ├── forwards
│       │       │   └── main.yml
│       │       └── remote_files
│       │           └── main.yml
│       ├── templates
│       │   ├── input_basics.j2
│       │   ├── input_remote.j2
│       │   ├── input_remote_module.j2
│       │   ├── input_template.j2
│       │   ├── output_elasticsearch.j2
│       │   ├── output_files.j2
│       │   ├── output_forwards.j2
│       │   ├── output_remote_files.j2
│       │   ├── ovirt_input_template.j2
│       │   ├── rsyslog.conf.j2
│       │   └── rules.conf.j2
│       └── vars
│           ├── inputs
│           │   ├── basics
│           │   │   └── main.yml
│           │   ├── files
│           │   │   └── main.yml
│           │   ├── ovirt
│           │   │   └── main.yml
│           │   └── remote
│           │       └── main.yml
│           ├── main.yml
│           └── outputs
│               ├── elasticsearch
│               │   └── main.yml
│               ├── files
│               │   └── main.yml
│               ├── forwards
│               │   └── main.yml
│               └── remote_files
│                   └── main.yml
└── tasks
    └── main.yml
```

# How Logging role starts

When ansible-playbook is executed with a playbook pointing to the logging role,
it starts with tasks in logging/tasks/main.yml.
In the tasks, it evaluates the `logging_outputs`, `logging_inputs`, and `logging_flow` parameters in the loop
to pass the dictionaries to each subtasks and subvars.
The following is a format of the outputs/inputs/flows parameters for the `files` and `forwards` output.

## inputs/outputs/flows
```
logging_outputs: [1]
  - name: unique_output_name
    type: output_type [2]
	<<other_parameters>
  - name: unique_output_name
        .................
logging_inputs: [3]
  - name: unique_input_name
    type: input_type [4]
	<<other_parameters>
  - name: unique_input_name
        .................
logging_flows: [5]
  - name: unique_flow_name
    inputs: [ unique_input_name, ... ] [6]
    outputs: [ unique_output_name, ... ] [7]
  - name: unique_flow_name
        .................
```
[1]: `logging_outputs` are implemented in logging/roles/rsyslog/tasks/outputs/ and logging/roles/rsyslog/vars/outputs/.<br>
[2]: `output_type` is one of [elasticsearch, files, forwards]; the type matches the directory name in the `outputs` directory.<br>
[3]: `logging_inputs` are implemented in ./logging/roles/rsyslog/tasks/inputs/ and ./logging/roles/rsyslog/vars/inputs/.<br>
[4]: `input_type is one of [basics, files, ovirt]; the type matches the directory name in the `inputs` directory.<br>
[5]: logging_flows are used in the inputs (inputs/{basics,files,etc.}) to set the `call output_ruleset`.
[6]: inputs contains the list of unique_input_name(s).
[7]: outputs contains the list of unique_output_name(s).
