## Changelogs

### RHELPLAN-43536 - Support tls for the remote input and forwards output
https://github.com/linux-system-roles/logging/pull/126
- New variables for configuring tls are introduced
  - logging_pki - Specifying rsyslog encryption library
                  one of the implementations is allowed none, ptcp, tls, gtls, gnutls
                  Note: none->ptcp, tls,gtls,gnutls->gtls
                  Default to ptcp (== no tls)
  - logging_pki_files - list of pki files dict
    logging_pki_files:

### Support imuxsock in the basics input
https://github.com/linux-system-roles/logging/pull/127
- In the basics input, if use_imuxsock is set to true, it reads logs via imuxsock instead of imjournal.

### RHELPLAN-42379 Support oVirt input
https://github.com/linux-system-roles/logging/pull/113/
- Replacing the rsyslog_default functionality with the combination of the basic input and the default files output.
- Stop generating 40-send-targets-only.conf which is taken over by the above change.

### cleanup.yml files are removed from logging role
https://github.com/linux-system-roles/logging/pull/118
- Unused cleanup.yml task files are removed.

### RHELPLAN-32453 - Add remote inputs (imtcp, imptcp, imudp) and their remote_files outputs supports
https://github.com/linux-system-roles/logging/pull/116
- Remote inputs are separated from the basics input.
- Output to the local files for the remote inputs are separated from the files output.

### RHELPLAN-32351 Add the flow control between inputs and outputs
https://github.com/linux-system-roles/logging/pull/100/
- Variable name change
  logs_collections is renamed to logging_inputs.
- New variable
  logs_flows is introduced.
