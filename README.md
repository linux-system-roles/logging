# linux-system-roles/logging

## Table of Contents

<!--ts-->
  * [Background](#background)
  * [Definitions](#definitions)
  * [Logging Configuration](#logging-configuration)
    * [Brief overview](#brief-overview)
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
  * [Providers](#providers)
  * [Tests](#tests)
  * [Implementation Details](#implementation-details)
<!--te-->

## Background

Logging role is an abstract layer for provisioning and configuring the logging system. Currently, rsyslog is the only supported provider.

In the nature of logging, there are multiple ways to read logs and multiple ways to output them. For instance, the logging system may read logs from local files, or read them from systemd/journal, or receive them from the other logging system over the network. Then, the logs may be stored in the local files in the /var/log directory, or sent to Elasticsearch, or forwarded to other logging system. The combination between the inputs and the outputs needs to be flexible. For instance, you may want to inputs from journal stored just in the local file, while inputs read from files stored in the local log files as well as forwarded to the other logging system.

To satisfy such requirements, logging role introduced 3 primary variables `logging_inputs`, `logging_outputs`, and `logging_flows`. The inputs are represented in the list of `logging_inputs` dictionary, the outputs are in the list of `logging_outputs` dictionary, and the relationship between them are defined as a list of `logging_flows` dictionary. The details are described in [Logging Configuration](#logging-configuration).

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

## Logging Configuration

### Brief overview

Logging role allows to have variables `logging_inputs`, `logging_outputs`, and `logging_flows` with additional options to configure logging system such as `rsyslog`.

Currently, the logging role supports four types of logging [inputs](tasks/inputs/): `basics`, `files`, `ovirt`, and `remote`.  And four types of [outputs](tasks/outputs/): `elasticsearch`, `files`, `forwards`, and `remote_files`.  To deploy configuration files with these inputs and outputs, specify the inputs as `logging_inputs` and the outputs as `logging_outputs`. To define the flows from inputs to outputs, use `logging_flows`.  The `logging_flows` has three keys `name`, `inputs`, and `outputs`, where `inputs` is a list of `logging_inputs name` values and `outputs` is a list of `logging_outputs name` values.

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
### Variables

#### Logging_inputs options

`logging_inputs`: A list of following dictionary to configure inputs.
- common keys
  - `name`: Unique name of the input. Used in the `logging_flows` inputs list and a part of the generated config filename.
  - `type`: Type of the input element. Currently, `basics`, `files`, `ovirt`, and `remote` are supported. The `type` is used to specify a task type which corresponds to a directory name in roles/rsyslog/{tasks,vars}/inputs/.
  - `state`: State of the configuration file. `present` or `absent`. Default to `present`.

- `basics` type - `basics` input supports reading logs from systemd journal or systemd unix socket.<br>
  **available options**
  - `kernel_message`: Load `imklog` if set to `true`. Default to `false`.
  - `use_imuxsock`: Use `imuxsock` instead of `imjournal`. Default to `false`.
  - `ratelimit_burst`: Maximum number of messages that can be emitted within ratelimit_interval. Default to `20000` if use_imuxsock is false. Default to `200` if use_imuxsock is true.
  - `ratelimit_interval`: Interval to evaluate ratelimit_burst. Default to `600` seconds if use_imuxsock is false. Default to `0` if use_imuxsock is true. 0 indicates ratelimiting is turned off.
  - `persist_state_interval`: Journal state is persisted every value messages. Default to `10`. Effective only when use_imuxsock is false.

- `files` type - `files` input supports reading logs from the local files.<br>
  **available options**
  - `input_log_path`: File name to be read by the imfile plugin. The value should be full path. Wildcard '\*' is allowed in the path.  Default to `/var/log/containers/*.log`.

- `ovirt` type - `ovirt` input supports oVirt specific inputs.<br>
   For the details, visit [oVirt Support](../../design_docs/rsyslog_ovirt_support.md).

- `remote` type - `remote` input supports receiving logs from the remote logging system over the network. This input type makes rsyslog a server.<br>
  **available options**
  - `udp_port`: UDP port number to listen. Default to `514`.
  - `tcp_port`: TCP port number to listen. Default to `514`.
  - `pki_authmode`: Specifying the default network driver authentication mode. Default to `x509/name`.
  - `permitted_peers`: List of hostnames, IP addresses or wildcard DNS domains which will be allowed by the `logging` server to connect and send logs over TLS. Default to ['\*.{{ logging_domain }}']

#### Logging_outputs options

`logging_outputs`: A list of following dictionary to configure outputs.
- common keys
  - `name`: Unique name of the output. Used in the `logging_flows` outputs list and a part of the generated config filename.
  - `type`: Type of the output element. Currently, `elasticsearch`, `files`, `forwards`, and `remote_files` are supported. The `type` is used to specify a task type which corresponds to a directory name in roles/rsyslog/{tasks,vars}/outputs/.
  - `state`: State of the configuration file. `present` or `absent`. Default to `present`.

- `elasticsearch` type - `elasticsearch` output supports sending logs to Elasticsearch. It is available only when the input is `ovirt`. Assuming Elasticsearch is already configured and running.<br>
  **available options**
  - `server_host`: Host name Elasticsearch is running on. **Required**.
  - `server_port`: Port number Elasticsearch is listening to. Default to `9200`.
  - `index_prefix`: Elasticsearch index prefix the particular log will be indexed to. **Required**.
  - `input_type`: Specifying the input type. Currently only type `ovirt` is supported. Default to `ovirt`.
  - `retryfailures`: Specifying whether retries or not in case of failure. Allowed value is `true` or `false`.  Default to `true`.
  - `use_cert`: If true, key/certificates are used to access Elasticsearch. Triplets {`ca_cert`, `cert`, `private_key`} and/or {`ca_cert_src`, `cert_src`, `private_key_src`} should be configured. Default to `true`.
  - `ca_cert`: Path to CA cert for Elasticsearch.  Default to `/etc/rsyslog.d/es-ca.crt`
  - `cert`: Path to cert to connect to Elasticsearch.  Default to `/etc/rsyslog.d/es-cert.pem`.
  - `private_key`: Path to key to connect to Elasticsearch.  Default to `/etc/rsyslog.d/es-key.pem`.
  - `ca_cert_src`: Local CA cert file path which is copied to the target host. If `ca_cert` is specified, it is copied to the location. Otherwise, to logging_config_dir.
  - `cert_src`: Local cert file path which is copied to the target host. If `cert` is specified, it is copied to the location. Otherwise, to logging_config_dir.
  - `private_key_src`: Local key file path which is copied to the target host. If `private_key` is specified, it is copied to the location. Otherwise, to logging_config_dir.

- `files` type - `files` output supports storing logs in the local files usually in /var/log.<br>
  **available options**
  - `facility`: Facility; default to `*`.
  - `severity`: Severity; default to `*`.
  - `exclude`: Exclude list; default to none.
  - `path`: Path to the output file.

  Unless the above options are given, these local file outputs are configured.
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

- `forwards` type - `forwards` output sends logs to the remote logging system over the network. This is for the client rsyslog.<br>
  **available options**
  - `facility`: Facility; default to `*`.
  - `severity`: Severity; default to `*`.
  - `protocol`: Protocol; `tcp` or `udp`; default to `tcp`.
  - `target`: Target host (fqdn). **Required**.
  - `port`: Port; default to 514.
  - `pki_authmode`: Specifying the default network driver authentication mode. Default to `x509/name`.
  - `permitted_peers`: Hostname, IP addresses or wildcard DNS domain which will be allowed by the `logging` server to connect and send logs over TLS. Default to '\*.{{ logging_domain }}'

- `remote_files` type - `remote_files` output stores logs to the local files per remote host and program name originated the logs.<br>
  **available options**
  - `facility`: Facility; default to `*`.
  - `severity`: Severity; default to `*`.
  - `exclude`: Exclude list; default to none.
  - `async_writing`: If set to `true`, the files are written asynchronously. Allowed value is `true` or `false`. Default to `false`.
  - `client_count`: Count of client logging system supported this rsyslog server. Default to `10`.
  - `io_buffer_size`: Buffer size used to write output data. Default to `65536` bytes.
  - `remote_log_path`: Full path to store the filtered logs.
                       This is an example to support the per host output log files
                       `/path/to/output/dir/%HOSTNAME%/%PROGRAMNAME:::secpath-replace%.log`
  - `remote_sub_path`: Relative path to logging_system_log_dir to store the filtered logs.

  if both `remote_log_path` and `remote_sub_path` are _not_ specified, the remote_file output configured with the following settings.
  ```
  template(
    name="RemoteMessage"
    type="string"
    string="/var/log/remote/msg/%HOSTNAME%/%PROGRAMNAME:::secpath-replace%.log"
  )
  template(
    name="RemoteHostAuthLog"
    type="string"
    string="/var/log/remote/auth/%HOSTNAME%/%PROGRAMNAME:::secpath-replace%.log"
  )
  template(
    name="RemoteHostCronLog"
    type="string"
    string="/var/log/remote/cron/%HOSTNAME%/%PROGRAMNAME:::secpath-replace%.log"
  )
  template(
    name="RemoteHostMailLog"
    type="string"
    string="/var/log/remote/mail/%HOSTNAME%/%PROGRAMNAME:::secpath-replace%.log"
  )
  ruleset(name="unique_remote_files_output_name") {
    authpriv.*   action(name="remote_authpriv_host_log" type="omfile" DynaFile="RemoteHostAuthLog")
    *.info;mail.none;authpriv.none;cron.none action(name="remote_message" type="omfile" DynaFile="RemoteMessage")
    cron.*       action(name="remote_cron_log" type="omfile" DynaFile="RemoteHostCronLog")
    mail.*       action(name="remote_mail_service_log" type="omfile" DynaFile="RemoteHostMailLog")
  }
  ```

#### Logging_flows options

  - `name`: Unique name of the flow.
  - `inputs`: A list of inputs, from which processing log messages starts.
  - `outputs`: A list of outputs. to which the log messages are sent.

#### Security options

These variables are set in the same level of the `logging_inputs`, `logging_output`, and `logging_flows`.

- `logging_pki`: Specifying an encryption.
  One of `none`, `ptcp`, `tls`, `gtls`, and `gnutls`. Default to `ptcp`.
  Note: `none`=`ptcp`, `tls`=`gtls`=`gnutls`.
  When `logging_pki` is _not_ `ptcp`, i.e., `tls` or its alias, the logging system is configured to use tls.
- `logging_pki_files`: Specifying either of the paths of the ca_cert, cert, and key on the control host or
  the paths of theirs on the managed host or both of them.
  The usage of `logging_pki_files` depends upon the value of `logging_pki`.
  If `logging_pki` is `ptcp`, `logging_pki_files` is ignored. 
  If `logging_pki` is not `ptcp`, `ca_cert_src` and/or `ca_cert` is required.
  If both `cert_src` and `cert` are not given, certificate for the logging system is not configured.
  If both `private_key_src` and `private_key` are not given, private key for the logging system is not configured.
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
- `logging_domain`: The default DNS domain used to accept remote incoming logs from remote hosts. Default to "{{ ansible_domain if ansible_domain else ansible_hostname }}"

#### Server performance optimization options

These variables are set in the same level of the `logging_inputs`, `logging_output`, and `logging_flows`.

- `logging_tcp_threads`: Input thread count listening on the plain tcp (ptcp) port. Default to `1`.
- `logging_udp_threads`: Input thread count listening on the udp port. Default to `1`.
- `logging_udp_system_time_requery`: Every `value` OS system calls, get the system time. Recommend not to set above 10. Default to `2` times.
- `logging_udp_batch_size`: Maximum number of udp messages per OS system call. Recommend not to set above 128. Default to `32`.
- `logging_server_queue_type`: Type of queue. `FixedArray` is available. Default to `LinkedList`.
- `logging_server_queue_size`: Maximum number of messages in the queue. Default to `50000`.
- `logging_server_threads`: Number of worker threads. Default to `logging_tcp_threads` + `logging_udp_threads`.

#### Other options

These variables are set in the same level of the `logging_inputs`, `logging_output`, and `logging_flows`.

- `logging_enabled`: When 'true', logging role will deploy specified configuration file set. Default to 'true'.
- `logging_mark`: Mark message periodically by immark, if set to `true`. Default to `false`.
- `logging_mark_interval`: Interval for `logging_mark` in seconds. Default to `3600`.
- `logging_purge_original_conf`: `true` or `false`. If set to `true`, files in /etc/rsyslog.d are purged.
- `logging_system_log_dir`: Directory where the local log output files are placed. Default to `/var/log`.

### Update and Delete

Due to the nature of ansible idempotency, if you run ansible-playbook multiple times without changing any variables and options, no changes are made from the second time. If some changes are made, only the rsyslog configuration files affected by the changes are recreated. To delete any existing rsyslog input or output config files generated by the previous ansible-playbook run, you need to add "state: absent" to the dictionary to be deleted (in this case, input_nameA and output_name0). And remove the flow dictionary related to the input and output as follows.
```
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

## Configuration Examples

### Standalone configuration

1. Deploying `basics input` reading logs from systemd journal and implicit `files output` to write to the local files.
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

2. Deploying `basics input` reading logs from systemd unix socket and `files output` to write to the local files.
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

3. Deploying `basics input` reading logs from systemd journal and `files output` to write to the individually configured local files.
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

4. Deploying `files input` reading logs from local files and `files output` to write to the individually configured local files.
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

5. Deploying `files input` reading logs from a local file and `elasticsearch output` to store the logs. Assuming the ca_cert, cert and key to connect to Elasticsearch are prepared.
```yaml
---
- name: Deploying basic input and elasticsearch output
  hosts: all
  roles:
    - linux-system-roles.logging
  vars:
    logging_inputs:
      - name: files_input
        type: files
        input_log_path: /var/log/containers/*.log
    logging_outputs:
      - name: elasticsearch_output
        type: elasticsearch
        server_host: your_target_host
        server_port: 9200
        index_prefix: project.
        input_type: ovirt
        ca_cert_src: /local/path/to/ca_cert
        cert_src: /local/path/to/cert
        private_key_src: /local/path/to/key
    logging_flows:
      - name: flow0
        inputs: [files_input]
        outputs: [elasticsearch_output]
```

### Client configuration

1. Deploying `basics input` reading logs from systemd journal and `forwards output` to forward the logs to the remote rsyslog.
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
        protocol: udp
        target: your_target_hostname
        port: 514
      - name: forward_output1
        type: forwards
        facility: mail
        protocol: tcp
        target: your_target_hostname
        port: 514
    logging_flows:
      - name: flows0
        inputs: [basic_input]
        outputs: [forward_output0, forward_output1]
```

2. Deploying `files input` reading logs from a local file and `forwards output` to forward the logs to the remote rsyslog over tls. Assuming the ca_cert, cert and key files are prepared at the specified paths on the control host. The files are deployed to the default location `/etc/pki/tls/certs/`, `/etc/pki/tls/certs/`, and `/etc/pki/tls/private`, respectively.
```yaml
---
- name: Deploying files input and forwards output with certs
  hosts: clients
  roles:
    - linux-system-roles.logging
  vars:
    logging_pki: tls
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
        protocol: tcp
        target: your_target_host
        port: 6514
        pki_authmode: x509/name
        permitted_peers: '*.example.com'
    logging_flows:
      - name: flows0
        inputs: [basic_input]
        outputs: [forwards-severity_and_facility]
```

### Server configuration

1. Deploying `remote input` reading logs from remote rsyslog and `remote_files output` to write the logs to the local files under the directory named by the remote host name.
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
        udp_port: 514
      - name: remote_tcp_input
        type: remote
        tcp_port: 514
    logging_outputs:
      - name: remote_files_output
        type: remote_files
    logging_flows:
      - name: flow_0
        inputs: [remote_udp_input, remote_tcp_input]
        outputs: [remote_files_output]
```

2. Deploying `remote input` reading logs from remote rsyslog and `remote_files output` to write the logs to the configured local files with the tls setup supporting 20 clients. Assuming the ca_cert, cert and key files are prepared at the specified paths on the control host. The files are deployed to the default location `/etc/pki/tls/certs/`, `/etc/pki/tls/certs/`, and `/etc/pki/tls/private`, respectively.
```yaml
---
- name: Deploying remote input and remote_files output with certs
  hosts: server
  roles:
    - linux-system-roles.logging
  vars:
    logging_pki: tls
    logging_pki_files:
      - ca_cert_src: /local/path/to/ca_cert
        cert_src: /local/path/to/cert
        private_key_src: /local/path/to/key
    logging_inputs:
      - name: remote_tcp_input
        type: remote
        tcp_port: 6514
        permitted_peers: ['*.example.com', '*.test.com']
    logging_outputs:
      - name: remote_files_output0
        type: remote_files
        remote_log_path: /var/log/remote/%HOSTNAME%/%PROGRAMNAME:::secpath-replace%.log
        async_writing: true
        client_count: 20
        io_buffer_size: 8192
      - name: remote_files_output1
        type: remote_files
        remote_sub_path: others/%HOSTNAME%/%PROGRAMNAME:::secpath-replace%.log
    logging_flows:
      - name: flow_0
        inputs: [remote_udp_input, remote_tcp_input]
        outputs: [remote_files_output0, remote_files_output1]
```

## Providers

[Rsyslog](roles/rsyslog) - This documentation contains rsyslog specific information.

## Tests

[Automated CI-tests](tests) - This documentation shows how to execute CI tests in the [tests](tests) directory as well as how to debug when the test fails.

[Manual tests](design_docs/rsyslog_manual_tests.md) - This documentation shows how to run the logging role manually against the local host or a remote host.

## Implementation Details

[Design Documentations](design_docs)
