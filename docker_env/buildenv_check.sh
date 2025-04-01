#!/bin/sh

set -eu

CROSS_COMPILE="${CROSS_COMPILE:-""}"

COMMANDS=" \
cmake \
make \
"
result=0

echo_line(){
    echo "--------------------------------------------------------------------------------"
}

check_command_installation()
{
    for pkg in ${COMMANDS}; do
        PATH="${PATH}:/sbin:/usr/sbin:/usr/local/sbin" command -V "${pkg}" || result=1
    done
}

echo_line
echo "Verifying build environment commands:"
check_command_installation
echo_line

if [ "${result}" -ne 0 ]; then
    echo "ERROR: Missing preconditions, cannot continue."
    exit 1
fi

echo "Build environment OK"

exit 0
