# Changelog

## [1.9.3] - 2022-06-12

### Bug fixes

- Fix including a var file in set\_vars.yml

## [1.9.2] - 2022-05-06

### New features

- Bump tox-lsr version to 2.11.0; remove py37; add py310

## [1.9.1] - 2022-04-26

### New features

- support gather\_facts: false
- support setup-snapshot.yml

## [1.9.0] - 2022-04-05

### New features

- Add log handling in case the target Elasticsearch is unavailable
- RFE - support template, severity and facility options

### Bug fixes

- Add support for multiline logs in oVirt vdsm.log
- Fix failures reported by "tox -e qemu\_option -- --remove-cloud-init ..."
- Initialize tests\_enabled.yml by setting "logging\_purge\_confs: true"
- Bump tox-lsr version to 2.10.1

## [1.8.1] - 2022-01-27

### Bug fixes

- make purge and reset idempotent

## [1.8.0] - 2022-01-18

### New features

- Refactor logging\_purge\_confs and logging\_restore\_confs.

## [1.7.0] - 2022-01-11

### Bug fixes

- Add logging\_restore\_confs variable to restore backup.
- change recursive role symlink to individual role dir symlinks

## [1.6.2] - 2021-12-02

### New features

- Run the new tox test
- update tox-lsr version to 2.8.0
- Add a test case for "add missing quotes" to TEST CASE 0 in tests\_basics\_files.yml

## [1.6.1] - 2021-11-08

### Bug fixes

- missing quotes around immark module interval option
- add missing quotes

### New features

- update tox-lsr version to 2.7.1
- support python 39, ansible-core 2.12, ansible-plugin-scan
- Support ansible-core 2.11

## [1.6.0] - 2021-10-04

### Bug fixes

- Use {{ ansible\_managed | comment }} to fix multi-line ansible\_managed
- Performance improvement
- use apt-get install -y
- Eliminating redundant loop.
- Replacing seport module with the semanage command line.
- Add uid and pwd parameters
- test new version of tox-lsr
- Use the openssl command-line interface instead of the openssl module

## [1.5.1] - 2021-08-24

### Bug fixes

- Allowing the case, tls is false and key/certs vars are configured.
- Update copy tasks conditions with tls true
- baseosci - fix logging tests

## [1.5.0] - 2021-08-10

### New features

- Drop support for Ansible 2.8 by bumping the Ansible version to 2.9

## [1.4.1] - 2021-08-06

### Bug fixes

- do not warn about unarchive or leading slashes
- python2 renders server\_host list incorrectly
- FIX README false variable name
- use correct python-cryptography package

## [1.4.0] - 2021-07-28

### New features

- Add a support for list value to server\_host in the elasticsearch output
- Instead of the archive module, use "tar" command for backup.

## [1.3.1] - 2021-05-26

### Bug fixes

- Keep headers at 4-level max, do minor structural corrections
- Fixing "logging README.html is rendered incorrectly"
- Fixing "logging README.html examples are rendered incorrectly"
- Remove python-26 environment from tox testing
- update to tox-lsr 2.4.0 - add support for ansible-test sanity with docker
- Cleaning up yamllint line-length errors.
- use tox-lsr 2.3.0 and enable ansible-test
- CI: Add support for RHEL-9
- Collections - fix ansible-test errors

## [1.3.0] - 2021-02-22

### Bug fixes

- Default remote\_log\_path should use FROMHOST instead of HOSTNAME
- RELP: cert and key files should be deployed in the /etc/pki/tls folder
- RELP: wrong reference to the input on server side
- RELP: the port definition for client side is not honored
- Collections - fix ansible-test errors
- Integrating ELK with RHV-4.4 fails as RHVH is missing 'rsyslog-gnutls' package.
- use tox-lsr 2.2.0
- Issue: cert and key files should be deployed in the /etc/pki/tls folder
- Fixing bugs in permitted\_servers and permitted\_clients parameter in relp.
- use FROMHOST instead of HOSTNAME for remote files log file name
- Bug fixes found or introduced in the previous commit "Bug fix in relp\_output - there was inconsistencies in the parameters."
- Bug fixes in relp\_input and relp\_output
- support jinja 2.7
- Make the var load test compatible with old Jinja2

## [1.2.0] - 2021-01-20

### New features

- remove ansible 2.7 support from molecule
- use tox-lsr 1.0.2
- Fix centos6 repos; use standard centos images; add centos8
- Support oVirt input + elasticsearch output
- Refactoring CI test playbooks
- implementing complete configuration cleaning up
- use tox for ansible-lint instead of molecule
- use new tox-lsr plugin
- Fixing CI tests using tests/tasks/create\_tests\_certs.yml
- use github actions instead of travis

## [1.1.0] - 2020-11-04

### New features

- Eliminating design\_doc links from README.md.
- meta/main.yml: CI - add support for Fedora 33
- Moving design documents to linux-system-roles.github.io/documentation/design_docs/logging.
- support property-based filters in the files and forwards outputs
- elasticsearch - need to adjust jinja2 bool…
- lock ansible-lint version at 4.3.5; suppress role name lint warning
- sync collections related changes from template to logging role
- Adding "Port and SELinux" section to README.
- Lock ansible-lint on version 4.2.0
- Add imrelp support to inputs.

### Bug fixes

- Fixing yamllint errors.
- Instead of having four symlinks in tests/roles/linux-system-roles.logging, changing tests/roles/linux-system-roles.logging itself a symlink as most system roles do.
- Fixing a logic bug in elasticsearch output template.

## [1.0.0] - 2020-08-25

### Initial Release
