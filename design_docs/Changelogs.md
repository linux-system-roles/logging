## Changelogs

### RHELPLAN-42379 Support oVirt input
https://github.com/linux-system-roles/logging/pull/113/
- Replacing the rsyslog_default functionality with the combination of the basic input and the default files output.
- Stop generating 40-send-targets-only.conf which is taken over by the above change.

### RHELPLAN-32351 Add the flow control between inputs and outputs
https://github.com/linux-system-roles/logging/pull/100/
- Variable name change
  logs_collections is renamed to logging_inputs.
- New variable
  logs_flows is introduced.
