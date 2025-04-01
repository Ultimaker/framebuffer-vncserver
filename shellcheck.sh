#!/bin/sh
# ! run_shellcheck.sh has to be sh, not bash as the docker image that runs it does not
# include bash
#
# Copyright (C) 2019-2021 Ultimaker B.V.
#

# This script is mandatory in a repository, to make sure the shell scripts are correct and of good quality.

set -eu

SHELLCHECK_FAILURE="false"

# Add your scripts or search paths here
SHELLCHECK_PATHS="."

# Files to be ignored. Must contain the path relative to the repository root folder and separated by spaces
IGNORE_FILES="./vagrant.sh"

# shellcheck disable=SC2086
SCRIPTS="$(find ${SHELLCHECK_PATHS} -name '*.sh')"

for script in ${SCRIPTS}; do
    if echo "$IGNORE_FILES" | grep -qw "$script"; then
       echo "IGNORE: The file $script is in the Ignore List"
       continue
    fi

    if [ ! -r "${script}" ]; then
        echo
        echo "WARNING: skipping shellcheck for '${script}'."
        echo
        continue
    fi

    echo "Running shellcheck on '${script}'"
    shellcheck -x -C -f tty "${script}" || SHELLCHECK_FAILURE="true"
done

if [ "${SHELLCHECK_FAILURE}" = "true" ]; then
    echo "WARNING: One or more scripts did not pass shellcheck."
    exit 1
fi

echo "All scripts passed shellcheck."

exit 0
