#!/usr/bin/env bash

# Halt on error.
set -euo pipefail

source "${REFERENCE_DIR}/usr/local/lib/git_delete_stale_branches/git_delete_stale_branches"

_validate_number_of_arguments one two three 3
! _validate_number_of_arguments one two three 2
! _validate_number_of_arguments one two three 4

# vim: set filetype=sh fileformat=unix nowrap:
