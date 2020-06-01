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
      * [Other variables](#other-variables)
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

## Definitions

  - `logging_inputs` - List of logging inputs dictionary to specify input types.
    * `basics` - basic inputs configuring inputs from systemd journal or unix socket.
    * `files` - files inputs configuring inputs from local files.
    * `remote` - remote inputs configuring inputs from the other logging system over network.
    * `ovirt` - ovirt inputs configuring inputs from the oVirt system.
  - `logging_outputs` - List of logging outputs dictionary to specify output types.
    * `elasticsearch` - elasticsearch outputs configuring outputs to elasticsearch.
    * `files` - files outputs configuring outputs to the local files.
    * `forwards` - forwards outputs configuring outputs to the other logging system.
    * `remote_files` - remote files outputs configuring outputs from the other logging system to the local files.
  - `logging_flows` - List of logging flows dictionary to define relationships between logging inputs and outputs.
  - [`Rsyslog`](https://www.rsyslog.com/) - The logging role default log provider used for log processing.
  - [`Elasticsearch`](https://www.elastic.co/) - Elasticsearch is a distributed, search and analytic engine for all types of data. One of the supported outputs in the logging role.
  - `Message Queue` (kafka, amqp) - Not yet implemented
  - [`Viaq`](https://docs.okd.io/latest/install_config/aggregate_logging.html)- Common Logging based on OpenShift Aggregated Logging (OCP/Origin). - Not yet implemented

## Logging Configuration

### Brief overview

Logging role allows to have variables `logging_inputs`, `logging_outputs`, and `logging_flows` with additional options to configure logging system such as `rsyslog`.

Currently, the logging role supports four types of logging [inputs](tasks/inputs/): `basics`, `files`, `ovirt`, and `remote`.  And four types of [outputs](tasks/outputs/): `elasticsearch`, `files`, `forwards`, and `remote_files`.  To deploy configuration files with these inputs and outputs, specify the inputs as `logging_inputs` and the outputs as `logging_outputs`. To define the flows from inputs to outputs, use `logging_flows`.  The `logging_flows` has three keys `name`, `inputs`, and `outputs`, where `inputs` is a list of `logging_inputs name` values and `outputs` is a list of `logging_outputs name` values.

This is a schematic logging configuration to show log messages from input_nameA are passed to output_name0 and output_name1; log messages from input_nameB are passed only to output_name1.
```
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
  available keys
  - `kernel_message`: Load `imklog` if set to `true`. Default to `false`.
  - `use_imuxsock`: Use `imuxsock` instead of `imjournal`. Default to `false`.
  - `journal_ratelimit_burst`: The value is set to imjournal RateLimit.Burst. Default to 20000.
  - `journal_ratelimit_interval`: The value is set to imjournal RateLimit.Interval. Default to 600.
  - `journal_persist_state_interval`: The value is set to imjournal PersistStateInterval. Default to 10.

- `files` type - `files` input supports reading logs from the local files.<br>
  available keys 
  - `input_log_path`: File name to be read by the imfile plugin. The value should be full path. Wildcard '*' is allowed in the path.  Default to `/var/log/containers/*.log`.

- `ovirt` type - `ovirt` input supports oVirt specific inputs.<br>
   For the details, visit [oVirt Support](../../design_docs/rsyslog_ovirt_support.md).

- `remote` type - `remote` input supports receiving logs from the remote logging system over the network. This input type makes rsyslog a server.<br>
  available keys
  - `udp_port`: UDP port number to listen. Default to 514.
  - `tcp_port`: TCP port number to listen. Default to 514.
  - `tcp_tls_port`: TLS TCP number to listen. Default to 6515. To use tcp_tls_port, `logging_pki` and `logging_pki_files` need to be configured. They are described in [Other variables](#other-variables).

#### Logging_outputs options

`logging_outputs`: A list of following dictionary to configure outputs.
- common keys
  - `name`: Unique name of the output. Used in the `logging_flows` outputs list and a part of the generated config filename.
  - `type`: Type of the output element. Currently, `elasticsearch`, `files`, `forwards`, and `remote_files` are supported. The `type` is used to specify a task type which corresponds to a directory name in roles/rsyslog/{tasks,vars}/outputs/.
  - `state`: State of the configuration file. `present` or `absent`. Default to `present`.

- `elasticsearch` type - `elasticsearch` output supports sending logs to Elasticsearch. Assuming Elasticsearch is already configured and running.<br>
  available keys
  - `server_host`: Host name Elasticsearch is running on. Mandatory.
  - `server_port`: Port number Elasticsearch is listening to. Default to 9200.
  - `index_prefix`: Elasticsearch index prefix the particular log will be indexed to. Mandatory.
  - `input_type`: Specifying the input type. Currently only type `ovirt` is supported. Default to `ovirt`.
  - `retryfailures`: Specifying whether retries or not in case of failure. `on` or `off`.  Default to `on`.
  - `use_cert`: If true, key/certificates are used to access Elasticsearch. Triplets {`ca_cert`, `cert`, key`} and/or {`ca_cert_src`, `cert_src`, `key_src`} should be configured. Default to true.
  - `ca_cert`: Path to CA cert for Elasticsearch.  Default to '/etc/rsyslog.d/es-ca.crt' - `cert`: Path to cert to connect to Elasticsearch.  Default to '/etc/rsyslog.d/es-cert.pem'.
  - `key`: Path to key to connect to Elasticsearch.  Default to "/etc/rsyslog.d/es-key.pem".
  - `ca_cert_src`: Local CA cert file path which is copied to the target host. If `ca_cert` is specified, it is copied to the location. Otherwise, to logging_config_dir.
  - `cert_src`: Local cert file path which is copied to the target host. If `cert` is specified, it is copied to the location. Otherwise, to logging_config_dir.
  - `key_src`: Local key file path which is copied to the target host. If `key` is specified, it is copied to the location. Otherwise, to logging_config_dir.

- `files` type - `files` output supports storing logs in the local files usually in /var/log.<br>
  available keys
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
  available keys
  - `facility`: Facility; default to `*`.
  - `severity`: Severity; default to `*`.
  - `protocol`: Protocol; `tcp` or `udp`; default to `tcp`.
  - `target`: Target host (fqdn). Mandatory.
  - `port`: Port; default to 514.

-  available keys for `remote_files` type
  - `facility`: Facility; default to `*`.
  - `severity`: Severity; default to `*`.
  - `exclude`: Exclude list; default to none.
  - `remote_log_path`: Full path to store the filtered logs.
                       To support the per host output log files, we recommend to have the path like this:
                       /path/to/output/dir/%HOSTNAME%/%PROGRAMNAME:::secpath-replace%.log
  - `remote_sub_path`: Relative path to logging_system_log_dir to store the filtered logs.
                       E.g., subdir/%HOSTNAME%/%PROGRAMNAME:::secpath-replace%.log

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

#### Other variables

These variables are set in the same level of the `logging_inputs`, `logging_output`, and `logging_flows`.

- `logging_enabled`: When 'true', logging role will deploy specified configuration file set. Default to 'true'.
- `logging_pki`: Specifying an encryption. One of `none`, `ptcp`, `tls`, `gtls`, and `gnutls`. Default to `ptcp`.
                 Note: `none`=`ptcp`, `tls`=`gtls`=`gnutls`.
                 When `logging_pki` is _not_ `ptcp`, `rsyslog_pki_path`, `rsyslog_pki_realm`, `rsyslog_pki_ca`, `rsyslog_pki_crt`, `rsyslog_pki_key` are configured.
- `logging_pki_files`: Specifying a list of ca_cert, cert and key dictionary to specify the source of the files if any as well as the destination, which is set in the deployed config file. The configuration is used by the `remote` input and `forward` output.
``` 
  - type: ca_cert | cert | key
    src:  location of the file on the local host;
          if given, the file is deployed to dest value path.
    dest: path to be deployed on the target host;
          if given, the path is set to the config file.
          Default to /etc/pki/tls/certs/ca.crt for ca_cert
                     /etc/pki/tls/certs/cert.pem for cert
                     /etc/pki/tls/private/key.pem for key
``` 
- `logging_pki_authmode`: Specify the default network driver authentication mode. `x509/name` or `anon` are available: Default to "x509/name".
- `logging_domain`: The default DNS domain used to accept remote incoming logs from remote hosts. Default to {{ ansible_domain if ansible_domain else ansible_hostname }}
- `logging_permitted_peers`: List of hostnames, IP addresses or wildcard DNS domains which will be allowed by the `logging` server to connect and send logs over TLS.  Default to ['*.{{ logging_domain }}']
- `logging_send_permitted_peers`: List of hostnames, IP addresses or wildcard DNS domains which will be verified by the `logging` client and will allow to send logs to the remote server over TLS. Default to '{{ logging_permitted_peers }}'.
- `logging_mark`: Mark message periodically by immark, if set to `true`. Default to `false`.
- `logging_mark_interval`: Interval for `logging_mark` in seconds. Default to 3600.
- `logging_purge_original_conf`: `true` or `false`. If set to `true`, 
		logging_system_log_dir: /var/log

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
```
logging_inputs:
  - name: system_input
    type: basics
```
This is identical to the following setup.
```
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
```
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

3. Deploying `basics input` reading logs from systemd journal and `files output` to write to the configured local files.

```
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

4. Deploying `files input` reading logs from local files and `files output` to write to the configured local files.
```
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
```
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
            key_src: /local/path/to/key
        logging_flows:
          - name: flow0
            inputs: [files_input]
            outputs: [elasticsearch_output]
```

### Client configuration

1. Deploying `basics input` reading logs from systemd journal and `forwards output` to forward the logs to the remote rsyslog.
```
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

2. Deploying `files input` reading logs from a local file and `forwards output` to forward the logs to the remote rsyslog over tls. Assuming the ca_cert, cert and key files are prepared. The files are deployed to the default location `/etc/pki/tls/certs/`, `/etc/pki/tls/certs/`, and `/etc/pki/tls/private`, respectively.
```
logging_pki: tls
logging_pki_files:
  - type: ca_cert
    src: /local/path/to/ca_cert
  - type: cert
    src: /local/path/to/cert
  - type: key
    src: /local/path/to/key
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
logging_flows:
  - name: flows0
    inputs: [basic_input]
    outputs: [forwards-severity_and_facility]
```

### Server configuration

1. Deploying `remote input` reading logs from remote rsyslog and `remote_files output` to write the logs to the local files under the directory named by the remote host name.
```
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

2. Deploying `remote input` reading logs from remote rsyslog and `remote_files output` to write the logs to the configured local files with the tls setup. Assuming the ca_cert, cert and key files are prepared. The files are deployed to the default location `/etc/pki/tls/certs/`, `/etc/pki/tls/certs/`, and `/etc/pki/tls/private`, respectively.
```
logging_pki: tls
logging_pki_files:
  - type: ca_cert
    src: /local/path/to/ca_cert
  - type: cert
    src: /local/path/to/cert
  - type: key
    src: /local/path/to/key
logging_inputs:
  - name: remote_tcp_input
    type: remote
    tcp_tls_port: 6514
logging_outputs:
  - name: remote_files_output0
    type: remote_files
    remote_log_path: /var/log/remote/%HOSTNAME%/%PROGRAMNAME:::secpath-replace%.log
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
