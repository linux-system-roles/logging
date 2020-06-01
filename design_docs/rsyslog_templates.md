# Rsyslog

## templates

### Sub-configuration files in rsyslog.d

The [rules.conf.j2](../roles/rsyslog/templates/rules.conf.j2) is a template to generate
sub-configuration files based on the rules defined in the file.  Rsyslog configurations are implemented
as a combination of small pieces.

Each piece is defined in the logging role default yaml files as follows (a simple example):
```
- name: filename
  type: type
  options: |-
    configure_line0
    configure_line1
    .....
```

It is deployed to /etc/rsyslog.d/[0-9][0-9]-filename.conf, where [0-9][0-9] is determined with the type [1].  The "filename" is from the value of `name`.  By default, the suffix is `conf`.

[1] - rsyslog_weight_map:
| type                           | value |
| ------------------------------ | -----:|
| global, globals                | 05    |
| module, modules                | 10    |
| template, templates            | 20    |
| output, outputs                | 30    |
| service, services              | 30    |
| rule, rules, ruleset, rulesets | 50    |
| input, inputs                  | 90    |

The contents of the file:
```
configure_line0
configure_line1
.....
```

Further controls are available.
To change the file suffix to `system`:
```
- name: filename
  type: type
  suffix: 'system'
```
To change the preceding digits to 99:
```
- name: filename
  type: type
  weight: '99'
```
To use completely pre-determined filename:
```
- filename: 'fixed-filename.conf'
```
