#!/usr/bin/env bash

set -euo pipefail

FAILED_SERVERS=()
function failure {
  FAILED_SERVERS+=("$1")
}

echo "Running tests..."
echo

rm -rf .tests-output
mkdir -p .tests-output

PATH=~/.opam/default/bin:~/.nimble/bin:$PATH

# verible not available on mac.
# svls compilation takes forever and hogs CPU (takes 15 min).
# puppet is broken (https://github.com/puppetlabs/puppet-editor-services/issues/318)
# volar is also broken
ls -d tests/* | grep -v -e 'volar' -e 'puppet' -e 'verible' -e 'svls' -e 'ccls' -e 'svls' | xargs -I% basename % | xargs -I% -P 2 bash -c 'set -euo pipefail; export TEST=%; ((make setup | tee .tests-output/${TEST}.log) || true); make test | tee .tests-output/${TEST}.log'

echo
echo "------------------"
echo "| Tests complete |"
echo "------------------"
echo

# Get length of FAILED_SERVERS and exit if its more than one
if [ ${#FAILED_SERVERS[@]} -gt 0 ]; then
  >&2 echo "One or more servers failed: ${FAILED_SERVERS[@]}"
  exit 1
fi

echo "All servers passed!"

exit 0
