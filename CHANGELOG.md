Changelog
=========

[1.9.3] - 2022-06-12
--------------------

### New Features

- none

### Bug Fixes

- Fix including a var file in set\_vars.yml

### Other Changes

- none

[1.9.2] - 2022-05-06
--------------------

### New Features

- none

### Bug Fixes

- none

### Other Changes

- Bump tox-lsr version to 2.11.0; remove py37; add py310

[1.9.1] - 2022-04-26
--------------------

### New Features

- support gather\_facts: false

### Bug Fixes

- none

### Other Changes

- support setup-snapshot.yml

[1.9.0] - 2022-04-05
--------------------

### New Features

- Add log handling in case the target Elasticsearch is unavailable
- RFE - support template, severity and facility options
- Add support for multiline logs in oVirt vdsm.log

### Bug Fixes

- none

### Other Changes

- Fix failures reported by "tox -e qemu\_option -- --remove-cloud-init ..."
- Initialize tests\_enabled.yml by setting "logging\_purge\_confs: true"
- Bump tox-lsr version to 2.10.1

[1.8.1] - 2022-01-27
--------------------

### New Features

- none

### Bug Fixes

- make purge and reset idempotent

### Other Changes

- none

[1.8.0] - 2022-01-18
--------------------

### New Features

- Refactor logging\_purge\_confs and logging\_restore\_confs.

### Bug Fixes

- none

### Other Changes

- none

[1.7.0] - 2022-01-11
--------------------

### New Features

- Add logging\_restore\_confs variable to restore backup.

### Bug Fixes

- none

### Other Changes

- change recursive role symlink to individual role dir symlinks

[1.6.2] - 2021-12-02
--------------------

### New Features

- none

### Bug Fixes

- none

### Other Changes

- Run the new tox test
- update tox-lsr version to 2.8.0
- Add a test case for "add missing quotes" to TEST CASE 0 in tests\_basics\_files.yml

[1.6.1] - 2021-11-08
--------------------

### New Features

- support python 39, ansible-core 2.12, ansible-plugin-scan

### Bug Fixes

- missing quotes around immark module interval option

### Other Changes

- update tox-lsr version to 2.7.1

[1.6.0] - 2021-10-04
--------------------

### New Features

- Use {{ ansible\_managed | comment }} to fix multi-line ansible\_managed
- Performance improvement
- Replacing seport module with the semanage command line.
- Add uid and pwd parameters
- Use the openssl command-line interface instead of the openssl module

### Bug Fixes

- Eliminate redundant loop.

### Other Changes

- use apt-get install -y
- test new version of tox-lsr

[1.5.1] - 2021-08-24
--------------------

### New Features

- Allowing the case, tls is false and key/certs vars are configured.

### Bug Fixes

- Update copy tasks conditions with tls true

### Other Changes

- baseosci - fix logging tests

[1.5.0] - 2021-08-10
--------------------

### New Features

- Drop support for Ansible 2.8 by bumping the Ansible version to 2.9

### Bug Fixes

- none

### Other Changes

- none

[1.4.1] - 2021-08-06
--------------------

### New Features

- none

### Bug Fixes

- do not warn about unarchive or leading slashes
- python2 renders server\_host list incorrectly
- FIX README false variable name
- use correct python-cryptography package

### Other Changes

- none

[1.4.0] - 2021-07-28
--------------------

### New Features

- Add a support for list value to server\_host in the elasticsearch output
- Instead of the archive module, use "tar" command for backup.

### Bug Fixes

- none

### Other Changes

- none

[1.3.1] - 2021-05-26
--------------------

### New Features

- none

### Bug Fixes

- Keep headers at 4-level max, do minor structural corrections
- Fix "logging README.html is rendered incorrectly"
- Fix "logging README.html examples are rendered incorrectly"
- Clean up yamllint line-length errors.
- Fix ansible-test errors

### Other Changes

- Remove python-26 environment from tox testing
- update to tox-lsr 2.4.0 - add support for ansible-test sanity with docker
- use tox-lsr 2.3.0 and enable ansible-test
- CI: Add support for RHEL-9

[1.3.0] - 2021-02-22
--------------------

### New Features

- support jinja 2.7

### Bug Fixes

- Default remote\_log\_path should use FROMHOST instead of HOSTNAME
- RELP: cert and key files should be deployed in the /etc/pki/tls folder
- RELP: wrong reference to the input on server side
- RELP: the port definition for client side is not honored
- Fix ansible-test errors
- Integrating ELK with RHV-4.4 fails as RHVH is missing 'rsyslog-gnutls' package.
- Issue: cert and key files should be deployed in the /etc/pki/tls folder
- Fix bugs in permitted\_servers and permitted\_clients parameter in relp.
- Use FROMHOST instead of HOSTNAME for remote files log file name
- Bug fixes found or introduced in the previous commit "Bug fix in relp\_output - there was inconsistencies in the parameters."
- Bug fixes in relp\_input and relp\_output

### Other Changes

- use tox-lsr 2.2.0
- Make the var load test compatible with old Jinja2

[1.2.0] - 2021-01-20
--------------------

### New Features

- Add centos8

### Bug Fixes

- Fix centos6 repos; use standard centos images

### Other Changes

- remove ansible 2.7 support from molecule
- use tox-lsr 1.0.2
- Support oVirt input + elasticsearch output
- Refactoring CI test playbooks
- implementing complete configuration cleaning up
- use tox for ansible-lint instead of molecule
- use new tox-lsr plugin
- Fixing CI tests using tests/tasks/create\_tests\_certs.yml
- use github actions instead of travis

[1.1.0] - 2020-11-04
--------------------

### New Features

- Eliminating design\_doc links from README.md.
- meta/main.yml: CI - add support for Fedora 33
- Moving design documents to linux-system-roles.github.io/documentation/design_docs/logging.
- support property-based filters in the files and forwards outputs
- elasticsearch - need to adjust jinja2 bool
- Adding "Port and SELinux" section to README.
- Add imrelp support to inputs.

### Bug Fixes

- Fix yamllint errors.
- Instead of having four symlinks in tests/roles/linux-system-roles.logging, changing tests/roles/linux-system-roles.logging itself a symlink as most system roles do.
- Fix a logic bug in elasticsearch output template.

### Other Changes

- lock ansible-lint version at 4.3.5; suppress role name lint warning
- sync collections related changes from template to logging role

[1.0.0] - 2020-08-25
--------------------

### Initial Release
