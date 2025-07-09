Changelog
=========

[1.15.2] - 2025-07-09
--------------------

### Other Changes

- refactor: support ansible 2.19 (#458)

[1.15.1] - 2025-06-16
--------------------

### Other Changes

- ci: Add Fedora 42; use tox-lsr 3.9.0; use lsr-report-errors for qemu tests (#453)
- ci: Add support for bootc end-to-end validation tests (#454)
- tests: Update tests_combination for bootc end-to-end validation (#455)
- ci: Use ansible 2.19 for fedora 42 testing; support python 3.13 (#456)

[1.15.0] - 2025-05-15
--------------------

### New Features

- feat: Support this role in container builds (#444)

### Bug Fixes

- fix: Consider "degraded" systemd state as booted (#449)

### Other Changes

- ci: bump sclorg/testing-farm-as-github-action from 3 to 4 (#445)
- ci: bump tox-lsr to 3.8.0; rename qemu/kvm tests (#446)
- test: restart firewalld after dbus if firewalld is running (#447)
- refactor: Re-unify service disabling and stopping (#448)

[1.14.2] - 2025-04-23
--------------------

### Bug Fixes

- fix: Add a variable for rsyslog base package on Debian (#436)
- fix: Only remove rsyslog* packages, remove packages with command line (#440)

### Other Changes

- ci: ansible-plugin-scan is disabled for now (#430)
- ci: bump ansible-lint to v25; provide collection requirements for ansible-lint (#433)
- ci: Check spelling with codespell (#434)
- ci: Add test plan that runs CI tests and customize it for each role (#435)
- ci: In test plans, prefix all relate variables with SR_ (#437)
- ci: Fix bug with ARTIFACTS_URL after prefixing with SR_ (#438)
- ci: use tox-lsr 3.6.0; improve qemu test logging (#441)
- ci: skip storage scsi, nvme tests in github qemu ci (#442)

[1.14.1] - 2025-01-09
--------------------

### Other Changes

- ci: Use Fedora 41, drop Fedora 39 (#427)
- ci: Use Fedora 41, drop Fedora 39 - part two (#428)

[1.14.0] - 2024-11-12
--------------------

### New Features

- feat: support custom templates (#425)

[1.13.5] - 2024-10-30
--------------------

### Other Changes

- ci: ansible-test action now requires ansible-core version (#420)
- ci: add YAML header to github action workflow files (#421)
- refactor: Use vars/RedHat_N.yml symlink for CentOS, Rocky, Alma wherever possible (#423)

[1.13.4] - 2024-09-13
--------------------

### Other Changes

- test: restart logind and test (#418)

[1.13.3] - 2024-09-11
--------------------

### Other Changes

- test: restart dbus broker after restarting journald (#416)

[1.13.2] - 2024-08-29
--------------------

### Other Changes

- ci: Add workflow for ci_test bad, use remote fmf plan (#410)
- ci: Fix missing slash in ARTIFACTS_URL (#411)
- test: tests_combination.yml requires fact gathering (#413)
- ci: Add tags to TF workflow, allow more [citest bad] formats (#414)

[1.13.1] - 2024-08-01
--------------------

### Other Changes

- ci: Add tft plan and workflow (#403)
- ci: Update fmf plan to add a separate job to prepare managed nodes (#405)
- test: workaround a systemd issue in el10 restarting journald (#406)
- test: sort files to compare (#407)
- ci: Bump sclorg/testing-farm-as-github-action from 2 to 3 (#408)

[1.13.0] - 2024-07-23
--------------------

### New Features

- feat: add support for reopen_on_truncate for files input (#398)
- feat: support custom config files with logging_custom_config_files (#399)
- feat: add support for file and directory mode/owner/group for output files (#400)

### Other Changes

- test: use selinux for relp to fix test AVC (#401)

[1.12.9] - 2024-07-02
--------------------

### Bug Fixes

- fix: add support for EL10 (#395)

### Other Changes

- ci: ansible-lint action now requires absolute directory (#394)

[1.12.8] - 2024-06-11
--------------------

### Bug Fixes

- fix: Add check for "rsyslogd: error" in /var/log/messages in all tests (#388)

### Other Changes

- ci: use tox-lsr 3.3.0 which uses ansible-test 2.17 (#389)
- ci: tox-lsr 3.4.0 - fix py27 tests; move other checks to py310 (#391)
- ci: Add supported_ansible_also to .ansible-lint (#392)

[1.12.7] - 2024-05-21
--------------------

### Bug Fixes

- fix: Remove name="basics_imuxsock" parameter from imuxsock type input (#385)

### Other Changes

- tests: Fail when rsyslog errors in __default_system_log (#386)

[1.12.6] - 2024-04-04
--------------------

### Other Changes

- ci: Bump ansible/ansible-lint from 6 to 24 (#382)
- ci: Bump mathieudutour/github-tag-action from 6.1 to 6.2 (#383)

[1.12.5] - 2024-02-26
--------------------

### Other Changes

- ci: fix python unit test - copy pytest config to tests/unit (#379)
- test: restore journald /dev/log after imuxsock test (#380)

[1.12.4] - 2024-01-16
--------------------

### Other Changes

- ci: support ansible-lint and ansible-test 2.16 (#376)
- ci: Use supported ansible-lint action; run ansible-lint against the collection (#377)

[1.12.3] - 2023-12-08
--------------------

### Bug Fixes

- fix: avoid conf of RatelimitBurst when RatelimitInterval is zero (#373)
- fix: ansible-core-2.16 - only use to_nice_json for output formatting (#374)

### Other Changes

- ci: Bump actions/github-script from 6 to 7 (#370)
- refactor: get_ostree_data.sh use env shebang - remove from .sanity* (#371)
- docs: README.md: correct variable name journal_persist_state_interval (#372)

[1.12.2] - 2023-11-29
--------------------

### Other Changes

- refactor: improve support for ostree systems (#368)

[1.12.1] - 2023-11-07
--------------------

### Other Changes

- test: add tests for preserveFQDN, max_message_size (#366)

[1.12.0] - 2023-11-06
--------------------

### New Features

- feat: support for ostree systems (#360)
- feat: Add support for the global config option preserveFQDN with a new logg… (#362)
- feat: Add support for general queue and general action parameters (#364)

### Bug Fixes

- fix: check that logging_max_message_size is set, not rsyslog_max_message_size (#361)

### Other Changes

- Bump actions/checkout from 3 to 4 (#350)
- ci: add dump_packages to weekly_ci (#351)
- ci: use dump_packages.py callback to get packages used by role (#357)
- ci: tox-lsr version 3.1.1 (#359)
- ci: Fix implicit octal values in main.yml (#363)

[1.11.10] - 2023-09-08
--------------------

### Other Changes

- ci: Add markdownlint, test_html_build, and build_docs workflows (#344)

  - markdownlint runs against README.md to avoid any issues with
    converting it to HTML
  - test_converting_readme converts README.md > HTML and uploads this test
    artifact to ensure that conversion works fine
  - build_docs converts README.md > HTML and pushes the result to the
    docs branch to publish dosc to GitHub pages site.
  - Fix markdown issues in README.md
  
  Signed-off-by: Sergei Petrosian <spetrosi@redhat.com>

- docs: reformat pki params (#346)

  format the pki parameters just like all of the other section
  parameters
  
  Signed-off-by: Rich Megginson <rmeggins@redhat.com>

- docs: Make badges consistent, run markdownlint on all .md files (#347)

  - Consistently generate badges for GH workflows in README RHELPLAN-146921
  - Run markdownlint on all .md files
  - Add custom-woke-action if not used already
  - Rename woke action to Woke for a pretty badge
  
  Signed-off-by: Sergei Petrosian <spetrosi@redhat.com>

- ci: Remove badges from README.md prior to converting to HTML (#348)

  - Remove thematic break after badges
  - Remove badges from README.md prior to converting to HTML
  
  Signed-off-by: Sergei Petrosian <spetrosi@redhat.com>

[1.11.9] - 2023-07-19
--------------------

### Bug Fixes

- fix: facts being gathered unnecessarily (#341)

### Other Changes

- ci: Add pull request template and run commitlint on PR title only (#335)
- ci: Rename commitlint to PR title Lint, echo PR titles from env var (#336)
- ci: Add tests::uses_selinux tag (#338)
- ci: ansible-lint - ignore var-naming[no-role-prefix] (#339)
- refactor: ansible-lint - vars cannot be reserved names (#340)
- refactor: Use selinux role instead of selinux cli (#342)

[1.11.8] - 2023-05-26
--------------------

### Bug Fixes

- fix: work with ansible-core 2.15

### Other Changes

- docs: Consistent contributing.md for all roles - allow role specific contributing.md section
- docs: add Collection requirements section

[1.11.7] - 2023-04-13
--------------------

### Other Changes

- ansible-lint - use changed_when even for tasks with conditionals (#326)

[1.11.6] - 2023-04-06
--------------------

### Other Changes

- Fingerprint RHEL System Role managed config files (#324)
- Add README-ansible.md to refer Ansible intro page on linux-system-roles.github.io

[1.11.5] - 2023-01-20
--------------------

### New Features

- none

### Bug Fixes

- ansible-lint 6.x fixes (#311)

### Other Changes

- cleanup non-inclusive words.
- Add check for non-inclusive language

[1.11.4] - 2022-12-13
--------------------

### New Features

- none

### Bug Fixes

- tests: specify empty inputs, outputs, flows with purge (#308)

If there are any leftover defined variables that specify inputs, outputs, or flows,
purge will not remove those files since they are referred to.  This typically
happens when using `public: true` which leaves all of those role variables
defined in the public namespace.  The solution when cleaning up is to ensure
that none of the inputs, outputs, or flows is defined when using purge, to
guarantee that all of the config files are removed and none are leftover.

### Other Changes

- none

[1.11.3] - 2022-12-05
--------------------

### New Features

- none

### Bug Fixes

- use logging_purge_confs in relp test (#303)

On some platforms, there are no packages that put config files in
/etc/rsyslog.d - using `logging_enabled: false` after a test leaves
no files in /etc/rsyslog.d and the `$IncludeConfig /etc/rsyslog.d/*.conf`
then leaves rsyslogd in a state that it will not start and cause test
failures.
The solution is to use `logging_purge_confs: true` which "does the right
thing" when /etc/rsyslog.d is empty.
Fix the expected number of config files check.

### Other Changes

- none

[1.11.2] - 2022-11-19
--------------------

### New Features

- none

### Bug Fixes

- cert cleanup needs to use getcert stop-tracking (#300)

Need to use `getcert stop-tracking` when removing the cert, otherwise,
subsequent requests will hang if certmonger is tracking a non-existent
cert.

### Other Changes

- increase test log timeout; show log if failed

[1.11.1] - 2022-11-14
--------------------

### New Features

- none

### Bug Fixes

- none

### Other Changes

- support ansible-core 2.14, ansible-lint 6.x (#297)

The main issue was getting rid of `warn: false` for the
`command` module.  The other issues are related to ansible-lint 6.x

[1.11.0] - 2022-11-01
--------------------

### New Features

- Use the firewall role, the selinux role, and the certificate role from the logging role (#293)

- Introduce logging_manage_firewall to use the firewall role to manage
  the syslog ports. logging_manage_firewall is set to true, by default.
  If the variable is set to false, the firewall configuration is
  disabled.

- Introduce logging_manage_selinux to use the selinux role to manage
  the ports specified in the logging configuration. logging_manage_
  selinux is set to true, by default.  If the variable is set to false,
  the selinux configuration is disabled except the ports defined in the
  selinux policy.

- Add the test check task check_firewall_selinux.yml for verify the
  ports status.

- Use the certificate role to generate certificates in the logging role

- Introduce logging_certificates variable to specify parameters for
  using the certificate role.

When logging_manage_firewall and logging_manage_selinux are
set to false, it does not call the firewall role and the selinux
role, respectively.

The default value of logging_manage_firewall and logging_
manage_selinux are changed to false.

### Bug Fixes

- none

### Other Changes

- To avoid the CI conflicts on the control host when running tests
in parallel, create a temporary directory by tempfile to store
files used in the test.

[1.10.0] - 2022-07-28
--------------------

### New Features

- Support startmsg.regex and endmsg.regex in the files inputs.

Adds startmsg_regex and endmsg_regex options:
`startmsg_regex`: The regular expression that matches the start part of a message.
`endmsg_regex`: The regular expression that matches the last part of a message.

### Bug Fixes

- none

### Other Changes

- Fix a bash bug in changelog_to_tag.yml, which unexpectedly expanded "*"

- changelog_to_tag action - github action ansible test improvements

- Use GITHUB_REF_NAME as name of push branch; fix error in branch detection

Signed-off-by: Rich Megginson <rmeggins@redhat.com>

[1.9.4] - 2022-07-19
--------------------

### New Features

- none

### Bug Fixes

- support ansible-core-2.13

Looks like ansible-core-2.13 (or latest jinja3) does not support
constructs like this:
```
var: "{{ [some list] }} + {{ [other list] }}"
```
instead, the entire thing has to be evaluated in the same jinja
evaluation context:
```
var: "{{ [some list] + [other list] }}"
```

### Other Changes

- use gather_facts: true in tests_include_vars_from_parent

This test does not work with ANSIBLE_GATHERING=explicit - add
explicit gather_facts: true

- make min_ansible_version a string in meta/main.yml

The Ansible developers say that `min_ansible_version` in meta/main.yml
must be a `string` value like `"2.9"`, not a `float` value like `2.9`.

- Add CHANGELOG.md

- Modify CHANGELOG.md

- Replace the ATX style with the setext style for the header H1 and H2.
- Each changelog has 3 sections, "### New Features", "### Bug Fixes",
  and "Other Changes".
- If there is no items in a section, let it have "- none".

- Add changelog_to_tag.yml to .github/workflows

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
- update to tox-lsr 2.4.0 - add support for ansible-test with docker
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
