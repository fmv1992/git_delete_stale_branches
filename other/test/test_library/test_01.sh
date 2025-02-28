#!/usr/bin/env bash

# Halt on error.
set -euo pipefail

# Go to execution directory.
cd "$(dirname $(readlink -f "${0}"))"
cd "$(git rev-parse --show-toplevel)"
[[ -d ./.git ]]

n_args_=2
if (($# != n_args_)); then
    echo "Expected $n_args_ arguments. Got $#." > /dev/stderr
    exit 1
fi

# vim: set filetype=sh fileformat=unix nowrap:
