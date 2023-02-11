#!/bin/bash -eu

artifacts=/tmp/LSR_Logging9.$(date +%y%m%d-%H%M%S)

if [ -d $artifacts ]; then
  rm -rf "$artifacts"
fi
mkdir "$artifacts"

tests="tests_basics_files tests_files_elasticsearch tests_purge_reset \
tests_basics_forwards tests_files_files tests_relp \
tests_combination tests_imuxsock_files tests_remote \
tests_default tests_include_vars_from_parent tests_server \
tests_enabled tests_ovirt_elasticsearch tests_version"

for atest in $tests
do
tox -e qemu-ansible-core-2.14 -- --image-name rhel-9 \
--log-level info \
tests/$atest.yml 2>&1 | tee "$artifacts/$atest.out"
done
