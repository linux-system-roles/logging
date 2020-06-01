CI tests
========
The tests are implemented in tests/tests_*.yml, which are triggered when a pull request is submitted. Each tests_testname.yml is written in the ansible playbook. The test part is a task made from the vars having `logging_outputs`, `logging_inputs` and `logging_flows` variables, and checking the deployed results.

The tests are triggered when a pull request is submitted or updated.

You can manually run the tests, as well.
1. Download CentOS qcow2 image from https://cloud.centos.org/centos/.
2. Make sure standard-test-roles-inventory-qemu package is installed.
3. Run the following command from the `tests` directory, which spawns an openshift node locally and runs the test yml on it.
   ```
   TEST_SUBJECTS=/path/to/downloaded_your_CentOS_7_or_8_image.qcow2 ansible-playbook [-vvvv] -i /usr/share/ansible/inventory/standard-inventory-qcow2 tests_testname.yml
   ```
   When the test is done, the test environment is cleaned up.
4. If the test fails and you need to debug it, add `TEST_DEBUG=true` prior to `ansible-playbook`, which leaves the test environment.
5. Once the ansible-playbook is finished, you can ssh to the node as follows:
   ```
   ssh -p PID -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /tmp/inventory-cloudRANDOMSTR/identity root@127.0.0.3
   ```
   The PID is returned from the following command line.
   ```
   ps -ef | grep "linux-system-roles.logging.tests" | egrep -v grep | awk '{print $28}' | awk -F':' '{print $3}' | awk -F'-' '{print $1}'
   ```
5. When the debugging is done, run `ps -ef | grep standard-inventory-qcow2` and kill the pid to clean up the node.

For more details, see also https://github.com/linux-system-roles/test-harness.
