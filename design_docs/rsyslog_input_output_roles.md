# Rsyslog

## Input Roles

### basics

Basics input role handles following inputs.

#### Local inputs
- `imuxsock` - reads system logs from unix socket.  `off`, by default.  If `rsyslog_use_imuxsock` is set to `true`, `on`.
- `imjournal` - reads system logs from `systemd-journald`.
- `imklog` - reads kernel messages.  If `kernel-message` is in `rsyslog_capabilities`, `imklog` is enabled.  Disabled, by default.
- `imfile` - reads messages from file. If `file-input` is in `rsyslog_capabilities`, `imfile` is enabled.  Disabled, by default.  Plus, when rsyslog_elasticsearch is configured, the messages are passed to the elasticsearch output config.  (Note: normalizing/reformatting is TBD.)

Basically, these system lots are handled by \*.system output roles, that `files` and `forwards` belong to.

#### Remote inputs
- `imudp` - receives remote logs via the udp socket. If `network` is in `rsyslog_capabilities` _and_ `rsyslog_send_over_tls_only` is `off`, `imudp` is enabled.  Disabled, by default.
- `imptcp` - receives remote logs via the plain tcp socket. If `network` is in `rsyslog_capabilities` _and_ `rsyslog_send_over_tls_only` is `off`, `imptcp` is enabled.  Disabled, by default.
- `imtcp` - receives remote logs via the tcp socket. If both `network` and `tls` are in `rsyslog_capabilities`, `imtdp` is enabled.  Disabled, by default

The remote logs are handed to \*.remote via remote ruleset.  Then, the logs are stored in separated files based on the source host name, program name, which is implemented in the output_roles/files.  (See also [tests_listen.yml](../tests/tests_listen.yml) for an example.)

### ovirt

### viaq

### viaq-k8s

## Output Roles

### elasticsearch

### files
- `builtin:omfile` - configure outputs to the local files.  If rsyslog_files_actions is not defined or empty, the default configuration - same as the file outputs to the part in rsyslog.conf in the rsyslog rpm package.  If rsyslog_files_actions are configured, the file outputs are generated according to the config params (See also [input/files output/action](logging_subsystem.md#inputfiles-outputaction) as well as [tests_files.yml](../tests/tests_files.yml) and [tests_files_forwards.yml](../tests/tests_files_forwards.yml) for examples.)

### forwards
- `omfwd` - configure outputs to forward over tcp or udp to the remote host.  If rsyslog_forwards_actions is not defined or empty, no omfwd is configured.  If rsyslog_forwards_actions are configured, the forwards outputs are generated according to the config params (See also [input/forwards output/action](logging_subsystem.md#inputforwards-outputaction) as well as [tests_forwards.yml](../tests/tests_forwards.yml) and [tests_files_forwards.yml](../tests/tests_files_forwards.yml) for examples.)
