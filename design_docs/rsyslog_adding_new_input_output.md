# How To Add A New Logging Input/Output.

A source of an rsyslog config file is a dictionary called "rule".
```
__rsyslog_conf_yourname_rule:
  - name: unique_name
    type: type defined in rsyslog_weight_map in [roles/rsyslog/vars/main.yml](../roles/rsyslog/vars/main.yml).
    sections:
      - options: discribing the contents of the configuration file
```
The rule is passed to the template [rule.j2](../roles/rsyslog/templates/rules.conf.j2) and written to the file.
Rsyslog configurations are implemented as a combination of small rules.

There is another step to convert the logging_inputs and logging_outputs parameters to the rule. This doc explains how to add a new logging input and/or output to the rsyslog role.

## Logging input

0. Choose an appropriate type name. In this example, call it `newinput`.

1. Create a directory `newinput` in [roles/rsyslog/tasks/inputs/](../roles/rsyslog/tasks/inputs/) and in [roles/rsyslog/vars/inputs/](../roles/rsyslog/vars/inputs/).

2. Create main.yml in roles/rsyslog/tasks/inputs/newinput and roles/rsyslog/vars/inputs/newinput. You could use [main.yml](tasks_inputs_main_template.yml) for the template of roles/rsyslog/tasks/inputs/newinput/main.yml; [main.yml](vars_inputs_main_template.yml) for roles/rsyslog/vars/inputs/newinput/main.yml.

3. The logic needs to be implemented in input_newinput.j2. [input_basics.j2](../roles/rsyslog/templates/input_basics.j2) could be used as a simple example. Note: the template must end with "{{ lookup('template', 'input_template.j2') }}".
   
## Logging output

0. Choose an appropriate type name. In this example, call it `newoutput`.

1. Create a directory `newoutput` in [roles/rsyslog/tasks/outputs/](../roles/rsyslog/tasks/outputs/) and in [roles/rsyslog/vars/outputs/](../roles/rsyslog/vars/outputs/).
   
2. Create main.yml in roles/rsyslog/tasks/outputs/newoutput and roles/rsyslog/vars/outputs/newoutput. You could use [main.yml](tasks_outputs_main_template.yml) for the template of roles/rsyslog/tasks/outputs/newoutput/main.yml; [main.yml](vars_outputs_main_template.yml) for roles/rsyslog/vars/outputs/newoutput/main.yml.

3. The logic needs to be implemented in output_newoutput.j2. [output_forwards.j2](../roles/rsyslog/templates/output_forwards.j2) could be used as a simple example. Note: the contents must be in `ruleset(name="{{ item.name }}") {` and `}`.
   
4. Just for outputs, add the following task to [tasks/main.yml](../tasks/main.yml) prior to the "Set rsyslog_outputs' task.
```
    - name: Set rsyslog_output_newoutput
      set_fact:
        rsyslog_output_newoutput: "{{ logging_outputs | selectattr('name', 'defined') | selectattr('type', 'defined') | selectattr('type', '==', 'newoutput') | list }}"
```
Then, add the newoutput to  the "Set rsyslog_outputs" task.
    - name: Set rsyslog_outputs
      set_fact:
        rsyslog_outputs: '{{ rsyslog_output_elasticsearch | d([]) }} + {{ rsyslog_output_files | d([]) }} + {{ rsyslog_output_forwards | d([]) }} + {{ rsyslog_output_remote_files | d([]) }} + {{ rsyslog_output_newoutput | d([]) }}'
```

## Additional notes:

### rsyslog config file name

Generated config file name is constructed of prefix 2 digits, keyword 'input' or 'output', given unique_name and a suffix '.conf'. I.e., using the next example, [0-9][0-9]-{input,output}-some_type-unique_name.conf.
```
__rsyslog_conf_yourname_rule:
  - name: unique_name
    type: some_type
    sections:
      - options: describing the contents of the configuration file
```
The generated configuration files are included by `$IncludeConfig /etc/rsyslog.d/*.conf` in /etc/rsyslog.conf. Thus, they are included in the prefix 2 digits order.  It is not common, but when you need to control the order by yourself, the 2 digits can be set by weight as follows. Using the example, 99-{input,output}-some_type-unique_name.conf is generated.
```
__rsyslog_conf_yourname_rule:
  - name: unique_name
    type: some_type
    weight: 99
    sections:
      - options: describing the contents of the configuration file
```
Or you can set your filename as follows. Using the example, your_filename is generated.
```
__rsyslog_conf_yourname_rule:
  - name: unique_name
    filename: your_filename
    sections:
      - options: describing the contents of the configuration file
```

### nocomment option

By default, the generated configuration file starts with a comment "# Ansible managed".  It could break some type of configurations.  For instance, "version=2" must be the first line in a rsyslog rulebase file.  To avoid having "# Ansible managed", set true to nocomment.
```
__rsyslog_conf_nocomment_rule:
  - name: unique_name
    type: some_type
    nocomment: true
    sections:
      - options: describing the contents of the configuration file
```

### path option

If there is a requirement to place the config file in some non-standard path, it is set with the `path:` key.
```
__rsyslog_conf_yourname_rule:
  - name: unique_name
    type: some_type
    path: some_path
    sections:
      - options: describing the contents of the configuration file
```
