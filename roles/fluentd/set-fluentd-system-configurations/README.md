## fluentd/fluentd-system-configurations

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


In order to set these variables add the required variables to the config.yml
or in the command line.

You don't need to update the configuration file if you wish to use default options.
