## fluentd/fluentd-setup

This role configures a Fluentd config.d directory, enables the service
and install the ca certificate.

This role configures fluentd system configutations.


Configuration
+++++++++++++

- `fluentd_log_level:` (default: `"info"`)

  This sets the logs verbosity level.
  Optional values are: `fatal`, `error`, `warn`, `info`, `debug`, `trace`.

- `fluentd_suppress_repeated_stacktrace:` (default: `"true"`)

  Determines whether to suppress repeated stacktrace.

- `fluentd_emit_error_log_interval:` (default: `"30"`)

  Determines the time interval between error log messages.
