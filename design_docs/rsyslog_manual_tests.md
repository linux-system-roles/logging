# Manual Tests

## Prepare test-playbook.yml
```
---
- name: Test playbook template
  hosts: nodes
  vars:
    ### REPLACE THIS LINE WITH ONE OF THE CONFIGURATION EXAMPLES.
    ### INDENTATION NEEDS TO BE ADJUSTED.
  roles:
    - role: logging
```
CONFIGURATION EXAMPLES are found [here](../roles/rsyslog/README.md#configuration-examples).

## Prepare a inventory file
### Target host is local.
local_inventory_file
```
[nodes]
your_local_hostname ansible_become=True
```

### Need to ssh to the target host.
remote_inventory_file
```
[nodes]
your_target_hostname ansible_connection=ssh ansible_ssh_user=your_account ansible_ssh_pass=your_password ansible_become=True
```

## Run ansible-playbook command
### Target host is local.

ansible-playbook [-vv] --connection local --become --become-user root -i local_inventory_file test-playbook.yml

### Target host is remote.

ansible-playbook [-vv] --become --become-user root -i remote_inventory_file test-playbook.yml
