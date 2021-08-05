# linux-system-roles/logging
![CI Testing](https://github.com/linux-system-roles/logging/workflows/tox/badge.svg)

## Table of Contents

<!--ts-->
  * [Background](#background)
  * [Definitions](#definitions)
  * [Logging Configuration Overview](#logging-configuration-overview)
  * [Variables](#variables)
    * [Logging_inputs options](#logging_inputs-options)
    * [Logging_outputs options](#logging_outputs-options)
    * [Logging_flows options](#logging_flows-options)
    * [Security options](#security-options)
    * [Server performance optimization options](#server-performance-optimization-options)
    * [Other options](#other-options)
  * [Update and Delete](#update-and-delete)
  * [Configuration Examples](#configuration-examples)
    * [Standalone configuration](#standalone-configuration)
    * [Client configuration](#client-configuration)
    * [Server configuration](#server-configuration)
    * [Client configuration with Relp](#client-configuration-with-relp)
    * [Server configuration with Relp](#server-configuration-with-relp)
  * [Port and SELinux](#port-and-selinux)
  * [Providers](#providers)
  * [Tests](#tests)
<!--te-->

## Background

Logging role is an abstract layer for provisioning and configuring the logging system. Currently, rsyslog is the only supported provider.

In the nature of logging, there are multiple ways to read logs and multiple ways to output them. For instance, the logging system may read logs from local files, or read them from systemd/journal, or receive them from the other logging system over the network. Then, the logs may be stored in the local files in the /var/log directory, or sent to Elasticsearch, or forwarded to other logging system. The combination between the inputs and the outputs needs to be flexible. For instance, you may want to inputs from journal stored just in the local file, while inputs read from files stored in the local log files as well as forwarded to the other logging system.

To satisfy such requirements, logging role introduced 3 primary variables `logging_inputs`, `logging_outputs`, and `logging_flows`. The inputs are represented in the list of `logging_inputs` dictionary, the outputs are in the list of `logging_outputs` dictionary, and the relationship between them are defined as a list of `logging_flows` dictionary. The details are described in [Logging Configuration Overview](#logging-configuration-overview).

## Requirements

This role is supported on RHEL/CentOS-7, RHEL/CentOS-8 and Fedora distributions.

## Definitions

- `logging_inputs` - List of logging inputs dictionary to specify input types.
    * `basics` - basic inputs configuring inputs from systemd journal or unix socket.
    * `files` - files inputs configuring inputs from local files.
    * `remote` - remote inputs configuring inputs from the other logging system over network.
    * `ovirt` - ovirt inputs configuring inputs from the oVirt system.
- `logging_outputs` - List of logging outputs dictionary to specify output types.
    * `elasticsearch` - elasticsearch outputs configuring outputs to elasticsearch. It is available only when the input is `ovirt`.
    * `files` - files outputs configuring outputs to the local files.
    * `forwards` - forwards outputs configuring outputs to the other logging system.
    * `remote_files` - remote files outputs configuring outputs from the other logging system to the local files.
- `logging_flows` - List of logging flows dictionary to define relationships between logging inputs and outputs.
- [`Rsyslog`](https://www.rsyslog.com/) - The logging role default log provider used for log processing.
- [`Elasticsearch`](https://www.elastic.co/) - Elasticsearch is a distributed, search and analytic engine for all types of data. One of the supported outputs in the logging role.

## Logging Configuration Overview

Logging role allows to have variables `logging_inputs`, `logging_outputs`, and `logging_flows` with additional options to configure logging system such as `rsyslog`.

Currently, the logging role supports four types of logging inputs: `basics`, `files`, `ovirt`, and `remote`.  And four types of outputs: `elasticsearch`, `files`, `forwards`, and `remote_files`.  To deploy configuration files with these inputs and outputs, specify the inputs as `logging_inputs` and the outputs as `logging_outputs`. To define the flows from inputs to outputs, use `logging_flows`.  The `logging_flows` has three keys `name`, `inputs`, and `outputs`, where `inputs` is a list of `logging_inputs name` values and `outputs` is a list of `logging_outputs name` values.

This is a schematic logging configuration to show log messages from input_nameA are passed to output_name0 and output_name1; log messages from input_nameB are passed only to output_name1.

```yaml
---
- name: a schematic logging configuration
  hosts: all
  roles:
    - linux-system-roles.logging
  vars:
    logging_inputs:
      - name: input_nameA
        type: input_typeA
      - name: input_nameB
        type: input_typeB
    logging_outputs:
      - name: output_name0
        type: output_type0
      - name: output_name1
        type: output_type1
    logging_flows:
      - name: flow_nameX
        inputs: [input_nameA]
        outputs: [output_name0, output_name1]
      - name: flow_nameY
        inputs: [input_nameB]
        outputs: [output_name1]
```

## Variables

### Logging_inputs options

`logging_inputs`: A list of the following dictionaries to configure inputs.

#### common keys

- `name`: Unique name of the input. Used in the `logging_flows` inputs list and a part of the generated config filename.
- `type`: Type of the input element. Currently, `basics`, `files`, `ovirt`, and `remote` are supported. The `type` is used to specify a task type which corresponds to a directory name in roles/rsyslog/{tasks,vars}/inputs/.
- `state`: State of the configuration file. `present` or `absent`. Default to `present`.

#### basics type

`basics` input supports reading logs from systemd journal or systemd unix socket.

Available options:
- `kernel_message`: Load `imklog` if set to `true`. Default to `false`.
- `use_imuxsock`: Use `imuxsock` instead of `imjournal`. Default to `false`.
- `ratelimit_burst`: Maximum number of messages that can be emitted within ratelimit_interval. Default to `20000` if use_imuxsock is false. Default to `200` if use_imuxsock is true.
- `ratelimit_interval`: Interval to evaluate ratelimit_burst. Default to `600` seconds if use_imuxsock is false. Default to `0` if use_imuxsock is true. 0 indicates ratelimiting is turned off.
- `persist_state_interval`: Journal state is persisted every value messages. Default to `10`. Effective only when use_imuxsock is false.

#### files type

`files` input supports reading logs from the local files.

Available options:
- `input_log_path`: File name to be read by the imfile plugin. The value should be full path. Wildcard '\*' is allowed in the path.  Default to `/var/log/containers/*.log`.

#### ovirt type

`ovirt` input supports oVirt specific inputs.

Available options:
- `subtype`: ovirt input subtype. Value is one of `engine`, `collectd`, and `vdsm`.
- `ovirt_env_name`: ovirt environment name. Default to `engine`.
- `ovirt_env_uuid`: ovirt uuid. Default to none.

Available options for engine and vdsm:
- `ovirt_elasticsearch_index_prefix`: Index prefix for elasticsearch. Default to `project.ovirt-logs`.
- `ovirt_engine_fqdn`: ovirt engine fqdn. Default to none.
- `ovirt_input_file`: ovirt input file. Default to `/var/log/ovirt-engine/test-engine.log` for `engine`; default to `/var/log/vdsm/vdsm.log` for `vdsm`.
- `ovirt_vds_cluster_name`: vds cluster name. Default to none.

Available options for collectd:
- `ovirt_collectd_port`: collectd port number. Default to `44514`.
- `ovirt_elasticsearch_index_prefix`: Index prefix for elasticsearch. Default to `project.ovirt-metrics`.

#### relp type

`relp` input supports receiving logs from the remote logging system over the network using relp.

Available options:
- `port`: Port number Relp is listening to. Default to `20514`. See also [Port and SELinux](#port-and-selinux).
- `tls`: If true, encrypt the connection with TLS. You must provide key/certificates and triplets {`ca_cert`, `cert`, `private_key`} and/or {`ca_cert_src`, `cert_src`, `private_key_src`}. Default to `true`.
- `ca_cert`: Path to CA cert to configure Relp with tls. Default to `/etc/pki/tls/certs/basename of ca_cert_src`.
- `cert`: Path to cert to configure Relp with tls. Default to `/etc/pki/tls/certs/basename of cert_src`.
- `private_key`: Path to key to configure Relp with tls. Default to `/etc/pki/tls/private/basename of private_key_src`.
- `ca_cert_src`: Local CA cert file path which is copied to the target host. If `ca_cert` is specified, it is copied to the location. Otherwise, to logging_config_dir.
- `cert_src`: Local cert file path which is copied to the target host. If `cert` is specified, it is copied to the location. Otherwise, to logging_config_dir.
- `private_key_src`: Local key file path which is copied to the target host. If `private_key` is specified, it is copied to the location. Otherwise, to logging_config_dir.
- `pki_authmode`: Specifying the authentication mode. `name` or `fingerprint` is accepted. Default to `name`.
- `permitted_clients`: List of hostnames, IP addresses, fingerprints(sha1), and wildcard DNS domains which will be allowed by the `logging` server to connect and send logs over TLS. Default to `['*.{{ logging_domain }}']`

#### remote type

`remote` input supports receiving logs from the remote logging system over the network.

Available options:
- `udp_ports`: List of UDP port numbers to listen. If set, the `remote` input listens on the UDP ports. No defaults. If both `udp_ports` and `tcp_ports` are set in a `remote` input item, `udp_ports` is used and `tcp_ports` is dropped. See also [Port and SELinux](#port-and-selinux).
- `tcp_ports`: List of TCP port numbers to listen. If set, the `remote` input listens on the TCP ports. Default to `[514]`. If both `udp_ports` and `tcp_ports` are set in a `remote` input item, `udp_ports` is used and `tcp_ports` is dropped. If both `udp_ports` and `tcp_ports` are not set in a `remote` input item, `tcp_ports: [514]` is added to the item. See also [Port and SELinux](#port-and-selinux).
- `tls`: Set to `true` to encrypt the connection using the default TLS implementation used by the provider. Default to `false`.
- `pki_authmode`: Specifying the default network driver authentication mode. `x509/name`, `x509/fingerprint`, or `anon` is accepted. Default to `x509/name`.
- `permitted_clients`: List of hostnames, IP addresses, fingerprints(sha1), and wildcard DNS domains which will be allowed by the `logging` server to connect and send logs over TLS. Default to `['*.{{ logging_domain }}']`

**Note:** There are 3 types of items in the remote type - udp, plain tcp and tls tcp. The udp type configured using `udp_ports`; the plain tcp type is configured using `tcp_ports` without `tls` or with `tls: false`; the tls tcp type is configured using `tcp_ports` with `tls: true` at the same time. Please note there might be only one instance of each of the three types. E.g., if there are 2 `udp` type items, it fails to deploy.

```yaml
  # Valid configuration example
  - name: remote_udp
    type: remote
    udp_ports: [514, ...]
  - name: remote_ptcp
    type: remote
    tcp_ports: [514, ...]
  - name: remote_tcp
    type: remote
    tcp_ports: [6514, ...]
    tls: true
    pki_authmode: x509/name
    permitted_clients: ['*.example.com']
```

```yaml
  # Invalid configuration example 1; duplicated udp
  - name: remote_udp0
    type: remote
    udp_ports: [514]
  - name: remote_udp1
    type: remote
    udp_ports: [1514]
```

```yaml
  # Invalid configuration example 2; duplicated tcp
  - name: remote_implicit_tcp
    type: remote
  - name: remote_tcp
    type: remote
    tcp_ports: [1514]
```

### Logging_outputs options

`logging_outputs`: A list of following dictionary to configure outputs.

#### common keys

- `name`: Unique name of the output. Used in the `logging_flows` outputs list and a part of the generated config filename.
- `type`: Type of the output element. Currently, `elasticsearch`, `files`, `forwards`, and `remote_files` are supported. The `type` is used to specify a task type which corresponds to a directory name in roles/rsyslog/{tasks,vars}/outputs/.
- `state`: State of the configuration file. `present` or `absent`. Default to `present`.

#### elasticsearch type

`elasticsearch` output supports sending logs to Elasticsearch. It is available only when the input is `ovirt`. Assuming Elasticsearch is already configured and running.

Available options:
- `server_host`: Host name Elasticsearch is running on. The value is a single host or list of hosts. **Required**.
- `server_port`: Port number Elasticsearch is listening to. Default to `9200`.
- `index_prefix`: Elasticsearch index prefix the particular log will be indexed to. **Required**.
- `input_type`: Specifying the input type. Currently only type `ovirt` is supported. Default to `ovirt`.
- `retryfailures`: Specifying whether retries or not in case of failure. Allowed value is `true` or `false`. Default to `true`.
- `tls`: If true, encrypt the connection with TLS. You must provide key/certificates and triplets {`ca_cert`, `cert`, `private_key`} and/or {`ca_cert_src`, `cert_src`, `private_key_src`}. Default to `true`.
- `use_cert`: [DEPRECATED] If true, encrypt the connection with TLS. You must provide key/certificates and triplets {`ca_cert`, `cert`, `private_key`} and/or {`ca_cert_src`, `cert_src`, `private_key_src`}. Default to `true`. Option `use_cert` is deprecated in favor of `tls` and `use_cert` will be removed in the next minor release.
- `ca_cert`: Path to CA cert for Elasticsearch. Default to `/etc/pki/tls/certs/basename of ca_cert_src`.
- `cert`: Path to cert to connect to Elasticsearch. Default to `/etc/pki/tls/certs/basename of cert_src`.
- `private_key`: Path to key to connect to Elasticsearch. Default to `/etc/pki/tls/private/basename of private_key_src`.
- `ca_cert_src`: Local CA cert file path which is copied to the target host. If `ca_cert` is specified, it is copied to the location. Otherwise, to logging_config_dir.
- `cert_src`: Local cert file path which is copied to the target host. If `cert` is specified, it is copied to the location. Otherwise, to logging_config_dir.
- `private_key_src`: Local key file path which is copied to the target host. If `private_key` is specified, it is copied to the location. Otherwise, to logging_config_dir.
- `uid`: If basic HTTP authentication is deployed, the user name is specified with this key.

logging_elasticsearch_password: If basic HTTP authentication is deployed, the password is specified with this global variable. Please be careful that this `logging_elasticsearch_password` is a global variable to be placed at the same level as `logging_output`, `logging_input`, and `logging_flows` are. Another things to be aware of are this `logging_elasticsearch_password` is shared among all the elasticsearch outputs. That is, the elasticsearch servers should share one password if there are multiple of servers. Plus, the uid and password are configured if both of them are found in the playbook. For instance, if there are multiple elasticsearch outputs and one of them is missing the `uid` key, then the configured output does not have the uid and password.

#### files type

`files` output supports storing logs in the local files usually in /var/log.

Available options:
- `facility`: Facility in selector; default to `*`.
- `severity`: Severity in selector; default to `*`.
- `exclude`: Exclude list used in selector; default to none.
- `property`: Property in property-based filter; no default
- `property_op`: Operation in property-based filter; In case of not `!`, put the `property_op` value in quotes; default to `contains`
- `property_value`: Value in property-based filter; default to `error`
- `path`: Path to the output file.

**Note:** Selector options and property-based filter options are exclusive. If Property-based filter options are defined, selector options will be ignored.

**Note:** Unless the above options are given, these local file outputs are configured.

```
  kern.*                                      /dev/console
  *.info;mail.none;authpriv.none;cron.none    /var/log/messages
  authpriv.*                                  /var/log/secure
  mail.*                                      -/var/log/maillog
  cron.*                                      -/var/log/cron
  *.emerg                                     :omusrmsg:*
  uucp,news.crit                              /var/log/spooler
  local7.*
```

#### forwards type

`forwards` output sends logs to the remote logging system over the network.

Available options:
- `facility`: Facility in selector; default to `*`.
- `severity`: Severity in selector; default to `*`.
- `exclude`: Exclude list used in selector; default to none.
- `property`: Property in property-based filter; no default
- `property_op`: Operation in property-based filter; In case of not `!`, put the `property_op` value in quotes; default to `contains`
- `property_value`: Value in property-based filter; default to `error`
- `target`: Target host (fqdn). **Required**.
- `udp_port`: UDP port number. Default to `514`.
- `tcp_port`: TCP port number. Default to `514`.
- `tls`: Set to `true` to encrypt the connection using the default TLS implementation used by the provider. Default to `false`.
- `pki_authmode`: Specifying the default network driver authentication mode. `x509/name`, `x509/fingerprint`, or `anon` is accepted. Default to `x509/name`.
- `permitted_server`: Hostname, IP address, fingerprint(sha1) or wildcard DNS domain of the server which this client will be allowed to connect and send logs over TLS. Default to `*.{{ logging_domain }}`

**Note:** Selector options and property-based filter options are exclusive. If Property-based filter options are defined, selector options will be ignored.

#### relp type

`relp` output sends logs to the remote logging system over the network using relp.

Available options:
- `target`: Host name the remote logging system is running on. **Required**.
- `port`: Port number the remote logging system is listening to. Default to `20514`.
- `tls`: If true, encrypt the connection with TLS. You must provide key/certificates and triplets {`ca_cert`, `cert`, `private_key`} and/or {`ca_cert_src`, `cert_src`, `private_key_src`}. Default to `true`.
- `ca_cert`: Path to CA cert to configure Relp with tls. Default to `/etc/pki/tls/certs/basename of ca_cert_src`.
- `cert`: Path to cert to configure Relp with tls. Default to `/etc/pki/tls/certs/basename of cert_src`.
- `private_key`: Path to key to configure Relp with tls. Default to `/etc/pki/tls/private/basename of private_key_src`.
- `ca_cert_src`: Local CA cert file path which is copied to the target host. If `ca_cert` is specified, it is copied to the location. Otherwise, to logging_config_dir.
- `cert_src`: Local cert file path which is copied to the target host. If `cert` is specified, it is copied to the location. Otherwise, to logging_config_dir.
- `private_key_src`: Local key file path which is copied to the target host. If `private_key` is specified, it is copied to the location. Otherwise, to logging_config_dir.
- `pki_authmode`: Specifying the authentication mode. `name` or `fingerprint` is accepted. Default to `name`.
- `permitted_servers`: List of hostnames, IP addresses, fingerprints(sha1), and wildcard DNS domains which will be allowed by the `logging` client to connect and send logs over TLS. Default to `['*.{{ logging_domain }}']`

#### remote_files type

`remote_files` output stores logs to the local files per remote host and program name originated the logs.

Available options:
- `facility`: Facility in selector; default to `*`.
- `severity`: Severity in selector; default to `*`.
- `exclude`: Exclude list used in selector; default to none.
- `property`: Property in property-based filter; no default
- `property_op`: Operation in property-based filter; In case of not `!`, put the `property_op` value in quotes; default to `contains`
- `property_value`: Value in property-based filter; default to `error`
- `async_writing`: If set to `true`, the files are written asynchronously. Allowed value is `true` or `false`. Default to `false`.
- `client_count`: Count of client logging system supported this rsyslog server. Default to `10`.
- `io_buffer_size`: Buffer size used to write output data. Default to `65536` bytes.
- `remote_log_path`: Full path to store the filtered logs.
                       This is an example to support the per host output log files
                       `/path/to/output/dir/%FROMHOST%/%PROGRAMNAME:::secpath-replace%.log`
- `remote_sub_path`: Relative path to logging_system_log_dir to store the filtered logs.

**Note:** Selector options and property-based filter options are exclusive. If Property-based filter options are defined, selector options will be ignored.

**Note:** If both `remote_log_path` and `remote_sub_path` are _not_ specified, the remote_file output configured with the following settings.

```
  template(
    name="RemoteMessage"
    type="string"
    string="/var/log/remote/msg/%FROMHOST%/%PROGRAMNAME:::secpath-replace%.log"
  )
  template(
    name="RemoteHostAuthLog"
    type="string"
    string="/var/log/remote/auth/%FROMHOST%/%PROGRAMNAME:::secpath-replace%.log"
  )
  template(
    name="RemoteHostCronLog"
    type="string"
    string="/var/log/remote/cron/%FROMHOST%/%PROGRAMNAME:::secpath-replace%.log"
  )
  template(
    name="RemoteHostMailLog"
    type="string"
    string="/var/log/remote/mail/%FROMHOST%/%PROGRAMNAME:::secpath-replace%.log"
  )
  ruleset(name="unique_remote_files_output_name") {
    authpriv.*   action(name="remote_authpriv_host_log" type="omfile" DynaFile="RemoteHostAuthLog")
    *.info;mail.none;authpriv.none;cron.none action(name="remote_message" type="omfile" DynaFile="RemoteMessage")
    cron.*       action(name="remote_cron_log" type="omfile" DynaFile="RemoteHostCronLog")
    mail.*       action(name="remote_mail_service_log" type="omfile" DynaFile="RemoteHostMailLog")
  }
```

### Logging_flows options

- `name`: Unique name of the flow.
- `inputs`: A list of inputs, from which processing log messages starts.
- `outputs`: A list of outputs. to which the log messages are sent.

### Security options

These variables are set in the same level of the `logging_inputs`, `logging_output`, and `logging_flows`.

#### logging_pki_files

Specifying either of the paths of the ca_cert, cert, and key on the control host or
the paths of theirs on the managed host or both of them.
When TLS connection is configured, `ca_cert_src` and/or `ca_cert` is required.
To configure the certificate of the logging system, `cert_src` and/or `cert` is required.
To configure the private key of the logging system, `private_key_src` and/or `private_key` is required.

```
  ca_cert_src:     location of the ca_cert on the control host; if given, the file is copied to the managed host.
  cert_src:        location of the cert on the control host; if given, the file is copied to the managed host.
  private_key_src: location of the key on the control host; if given, the file is copied to the managed host.
  ca_cert:     path to be deployed on the managed host; the path is also used in the rsyslog config.
               default to /etc/pki/tls/certs/<ca_cert_src basename>
  cert:        ditto
               default to /etc/pki/tls/certs/<cert_src basename>
  private_key: ditto
               default to /etc/pki/tls/private/<private_key_src basename>
```

#### logging_domain

The default DNS domain used to accept remote incoming logs from remote hosts. Default to "{{ ansible_domain if ansible_domain else ansible_hostname }}"

### Server performance optimization options

These variables are set in the same level of the `logging_inputs`, `logging_output`, and `logging_flows`.

- `logging_tcp_threads`: Input thread count listening on the plain tcp (ptcp) port. Default to `1`.
- `logging_udp_threads`: Input thread count listening on the udp port. Default to `1`.
- `logging_udp_system_time_requery`: Every `value` OS system calls, get the system time. Recommend not to set above 10. Default to `2` times.
- `logging_udp_batch_size`: Maximum number of udp messages per OS system call. Recommend not to set above 128. Default to `32`.
- `logging_server_queue_type`: Type of queue. `FixedArray` is available. Default to `LinkedList`.
- `logging_server_queue_size`: Maximum number of messages in the queue. Default to `50000`.
- `logging_server_threads`: Number of worker threads. Default to `logging_tcp_threads` + `logging_udp_threads`.

### Other options

These variables are set in the same level of the `logging_inputs`, `logging_output`, and `logging_flows`.

- `logging_enabled`: When 'true', logging role will deploy specified configuration file set. Default to 'true'.
- `logging_mark`: Mark message periodically by immark, if set to `true`. Default to `false`.
- `logging_mark_interval`: Interval for `logging_mark` in seconds. Default to `3600`.
- `logging_purge_confs`: `true` or `false`. If set to `true`, files in /etc/rsyslog.d are purged.
- `logging_system_log_dir`: Directory where the local log output files are placed. Default to `/var/log`.

### Update and Delete

Due to the nature of ansible idempotency, if you run ansible-playbook multiple times without changing any variables and options, no changes are made from the second time. If some changes are made, only the rsyslog configuration files affected by the changes are recreated. To delete any existing rsyslog input or output config files generated by the previous ansible-playbook run, you need to add "state: absent" to the dictionary to be deleted (in this case, input_nameA and output_name0). And remove the flow dictionary related to the input and output as follows.

```yaml
logging_inputs:
  - name: input_nameA
    type: input_typeA
    state: absent
  - name: input_nameB
    type: input_typeB
logging_outputs:
  - name: output_name0
    type: output_type0
    state: absent
  - name: output_name1
    type: output_type1
logging_flows:
  - name: flow_nameY
    inputs: [input_nameB]
    outputs: [output_name1]
```

If you want to remove all the configuration files previously configured, in addition to setting `state: absent` to each logging_inputs and logging_outputs item, add `logging_enabled: false` to the configuration variables as follows. It will eliminate the global and common configuration files, as well.

```yaml
logging_enabled: false
logging_inputs:
  - name: input_nameA
    type: input_typeA
    state: absent
  - name: input_nameB
    type: input_typeB
    state: absent
logging_outputs:
  - name: output_name0
    type: output_type0
    state: absent
  - name: output_name1
    type: output_type1
    state: absent
logging_flows:
  - name: flow_nameY
    inputs: [input_nameB]
    outputs: [output_name1]
```

## Configuration Examples

### Standalone configuration

Deploying `basics input` reading logs from systemd journal and implicit `files output` to write to the local files.

```yaml
---
- name: Deploying basics input and implicit files output
  hosts: all
  roles:
    - linux-system-roles.logging
  vars:
    logging_inputs:
      - name: system_input
        type: basics
```

The following playbook generates the same logging configuration files.

```yaml
---
- name: Deploying basics input and files output
  hosts: all
  roles:
    - linux-system-roles.logging
  vars:
    logging_inputs:
      - name: system_input
        type: basics
    logging_outputs:
      - name: files_output
        type: files
    logging_flows:
      - name: flow0
        inputs: [system_input]
        outputs: [files_output]
```

Deploying `basics input` reading logs from systemd unix socket and `files output` to write to the local files.

```yaml
---
- name: Deploying basics input using systemd unix socket and files output
  hosts: all
  roles:
    - linux-system-roles.logging
  vars:
    logging_inputs:
      - name: system_input
        type: basics
        use_imuxsock: true
    logging_outputs:
      - name: files_output
        type: files
    logging_flows:
      - name: flow0
        inputs: [system_input]
        outputs: [files_output]
```

Deploying `basics input` reading logs from systemd journal and `files output` to write to the individually configured local files.

```yaml
---
- name: Deploying basic input and configured files output
  hosts: all
  roles:
    - linux-system-roles.logging
  vars:
    logging_inputs:
      - name: system_input
        type: basics
    logging_outputs:
      - name: files_output0
        type: files
        severity: info
        exclude:
          - authpriv.none
          - auth.none
          - cron.none
          - mail.none
        path: /var/log/messages
      - name: files_output1
        type: files
        facility: authpriv,auth
        path: /var/log/secure
    logging_flows:
      - name: flow0
        inputs: [system_input]
        outputs: [files_output0, files_output1]
```

Deploying `files input` reading logs from local files and `files output` to write to the individually configured local files.

```yaml
---
- name: Deploying files input and configured files output
  hosts: all
  roles:
    - linux-system-roles.logging
  vars:
    logging_inputs:
      - name: files_input0
        type: files
        input_log_path: /var/log/containerA/*.log
      - name: files_input1
        type: files
        input_log_path: /var/log/containerB/*.log
    logging_outputs:
      - name: files_output0
        type: files
        severity: info
        exclude:
          - authpriv.none
          - auth.none
          - cron.none
          - mail.none
        path: /var/log/messages
      - name: files_output1
        type: files
        facility: authpriv,auth
        path: /var/log/secure
    logging_flows:
      - name: flow0
        inputs: [files_input0, files_input1]
        outputs: [files_output0, files_output1]
```

Deploying `files input` reading logs from local files and `files output` to write to the local files based on the property-based filters.

```yaml
---
- name: Deploying files input and configured files output
  hosts: all
  roles:
    - linux-system-roles.logging
  vars:
    logging_inputs:
      - name: files_input0
        type: files
        input_log_path: /var/log/containerA/*.log
      - name: files_input1
        type: files
        input_log_path: /var/log/containerB/*.log
    logging_outputs:
      - name: files_output0
        type: files
        property: msg
        property_op: contains
        property_value: error
        path: /var/log/errors.log
      - name: files_output1
        type: files
        property: msg
        property_op: "!contains"
        property_value: error
        path: /var/log/others.log
    logging_flows:
      - name: flow0
        inputs: [files_input0, files_input1]
        outputs: [files_output0, files_output1]
```

### Client configuration

Deploying `basics input` reading logs from systemd journal and `forwards output` to forward the logs to the remote rsyslog.

```yaml
---
- name: Deploying basics input and forwards output
  hosts: clients
  roles:
    - linux-system-roles.logging
  vars:
    logging_inputs:
      - name: basic_input
        type: basics
    logging_outputs:
      - name: forward_output0
        type: forwards
        severity: info
        target: your_target_hostname
        udp_port: 514
      - name: forward_output1
        type: forwards
        facility: mail
        target: your_target_hostname
        tcp_port: 514
    logging_flows:
      - name: flows0
        inputs: [basic_input]
        outputs: [forward_output0, forward_output1]
```

Deploying `files input` reading logs from a local file and `forwards output` to forward the logs to the remote rsyslog over tls. Assuming the ca_cert, cert and key files are prepared at the specified paths on the control host. The files are deployed to the default location `/etc/pki/tls/certs/`, `/etc/pki/tls/certs/`, and `/etc/pki/tls/private`, respectively.

```yaml
---
- name: Deploying files input and forwards output with certs
  hosts: clients
  roles:
    - linux-system-roles.logging
  vars:
    logging_pki_files:
      - ca_cert_src: /local/path/to/ca_cert
        cert_src: /local/path/to/cert
        private_key_src: /local/path/to/key
    logging_inputs:
      - name: files_input
        type: files
        input_log_path: /var/log/containers/*.log
    logging_outputs:
      - name: forwards_output
        type: forwards
        target: your_target_host
        tcp_port: your_target_port
        pki_authmode: x509/name
        permitted_server: '*.example.com'
    logging_flows:
      - name: flows0
        inputs: [basic_input]
        outputs: [forwards-severity_and_facility]
```

### Server configuration

Deploying `remote input` reading logs from remote rsyslog and `remote_files output` to write the logs to the local files under the directory named by the remote host name.

```yaml
---
- name: Deploying remote input and remote_files output
  hosts: server
  roles:
    - linux-system-roles.logging
  vars:
    logging_inputs:
      - name: remote_udp_input
        type: remote
        udp_ports: [514, 1514]
      - name: remote_tcp_input
        type: remote
        tcp_ports: [514, 1514]
    logging_outputs:
      - name: remote_files_output
        type: remote_files
    logging_flows:
      - name: flow_0
        inputs: [remote_udp_input, remote_tcp_input]
        outputs: [remote_files_output]
```

Deploying `remote input` reading logs from remote rsyslog and `remote_files output` to write the logs to the configured local files with the tls setup supporting 20 clients. Assuming the ca_cert, cert and key files are prepared at the specified paths on the control host. The files are deployed to the default location `/etc/pki/tls/certs/`, `/etc/pki/tls/certs/`, and `/etc/pki/tls/private`, respectively.

```yaml
---
- name: Deploying remote input and remote_files output with certs
  hosts: server
  roles:
    - linux-system-roles.logging
  vars:
    logging_pki_files:
      - ca_cert_src: /local/path/to/ca_cert
        cert_src: /local/path/to/cert
        private_key_src: /local/path/to/key
    logging_inputs:
      - name: remote_tcp_input
        type: remote
        tcp_ports: [6514, 7514]
        permitted_clients: ['*.example.com', '*.test.com']
    logging_outputs:
      - name: remote_files_output0
        type: remote_files
        remote_log_path: /var/log/remote/%FROMHOST%/%PROGRAMNAME:::secpath-replace%.log
        async_writing: true
        client_count: 20
        io_buffer_size: 8192
      - name: remote_files_output1
        type: remote_files
        remote_sub_path: others/%FROMHOST%/%PROGRAMNAME:::secpath-replace%.log
    logging_flows:
      - name: flow_0
        inputs: [remote_udp_input, remote_tcp_input]
        outputs: [remote_files_output0, remote_files_output1]
```

### Client configuration with Relp

Deploying `basics input` reading logs from systemd journal and `relp output` to send the logs to the remote rsyslog over relp.

```yaml
---
- name: Deploying basics input and relp output
  hosts: clients
  roles:
    - linux-system-roles.logging
  vars:
    logging_inputs:
      - name: basic_input
        type: basics
    logging_outputs:
      - name: relp_client
        type: relp
        target: logging.server.com
        port: 20514
        tls: true
        ca_cert_src: /path/to/ca.pem
        cert_src: /path/to/client-cert.pem
        private_key_src: /path/to/client-key.pem
        pki_authmode: name
        permitted_servers:
          - '*.server.com'
    logging_flows:
      - name: flow
        inputs: [basic_input]
        outputs: [relp_client]
```

### Server configuration with Relp

Deploying `relp input` reading logs from remote rsyslog and `remote_files output` to write the logs to the local files under the directory named by the remote host name.

```yaml
---
- name: Deploying remote input and remote_files output
  hosts: server
  roles:
    - linux-system-roles.logging
  vars:
    logging_inputs:
      - name: relp_server
        type: relp
        port: 20514
        tls: true
        ca_cert_src: /path/to/ca.pem
        cert_src: /path/to/server-cert.pem
        private_key_src: /path/to/server-key.pem
        pki_authmode: name
        permitted_clients:
          - '*.client.com'
          - '*.example.com'
    logging_outputs:
      - name: remote_files_output
        type: remote_files
    logging_flows:
      - name: flow
        inputs: [relp_server]
        outputs: [remote_files_output]
```

### Port and SELinux

SELinux is only configured to allow sending and receiving on the following ports by default:

```
syslogd_port_t        tcp   514, 20514
syslogd_port_t        udp   514, 20514
```

If other ports need to be configured, you can use [linux-system-roles/selinux](https://github.com/linux-system-roles/selinux) to manage SELinux contexts.

## Providers

- Rsyslog

## Tests

tests/README.md - This documentation shows how to execute CI tests in the tests directory as well as how to debug when the test fails.
