# CI tests

The tests are implemented in tests/tests_*.yml.

Rough naming convention of the tests - tests_inputname[_outputname].conf.

Tests are divided in to these groups.

- basics input - input from imjournal or imuxsock, and output to omfile or omfwd
  - tests_basics_files.yml
  - tests_basics_forwards.yml
  - tests_imuxsock_files.yml
- files input - input from imfile and output to omfile
  - tests_files_files.yml
- combination - input from imjournal and imfile, and output to omfile or omfwd
  - tests_combination.yml
- files_elasticsearch - input from imfile, and output to elasticsearch, including key/certs set up
  - tests_files_elasticsearch.yml
- ovirt - input from ovirt, and output to elasticsearch and omfile
  - tests_ovirt_elasticsearch.yml
- server - input from imudp, imtcp or imptcp, and output to omfile
  - tests_remote.yml
- relp - input from imrelp and output to omrelp
  - tests_relp.yml
- others
  - tests_default.yml
  - tests_enabled.yml
  - tests_version.yml

The CI tests are triggered when a pull request is submitted. Each tests_testname.yml is written in the ansible playbook format. The test part is a task made from the vars having `logging_outputs`, `logging_inputs` and `logging_flows` variables, and checking the deployed results.

The tests are used in the upstream as well as the downstream CI testing.

You can manually run the tests, as well.

1. Download CentOS qcow2 image from <https://cloud.centos.org/centos/>.
2. Make sure standard-test-roles-inventory-qemu package is installed.
3. Run the following command from the `tests` directory, which spawns an openshift node locally and runs the test yml on it.

   ```bash
   TEST_SUBJECTS=/path/to/downloaded_your_CentOS_7_or_8_image.qcow2 ansible-playbook [-vvvv] -i /usr/share/ansible/inventory/standard-inventory-qcow2 tests_testname.yml
   ```

   When the test is done, the test environment is cleaned up.
4. If the test fails and you need to debug it, add `TEST_DEBUG=true` prior to `ansible-playbook`, which leaves the test environment.
5. Once the ansible-playbook is finished, you can ssh to the node as follows:

   ```bash
   ssh -p PID -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /tmp/inventory-cloudRANDOMSTR/identity root@127.0.0.3
   ```

   The PID is returned from the following command line.

   ```bash
   ps -ef | grep "linux-system-roles.logging.tests" | egrep -v grep | awk '{print $28}' | awk -F':' '{print $3}' | awk -F'-' '{print $1}'
   ```

6. When the debugging is done, run `ps -ef | grep standard-inventory-qcow2` and kill the pid to clean up the node.

For more details, see also <https://github.com/linux-system-roles/test-harness>.
