#!/usr/bin/env bash

# Halt on error.
set -euo pipefail

source "${REFERENCE_DIR}/usr/local/lib/git_delete_stale_branches/git_delete_stale_branches"

validate_number_of_arguments 3 'error' one two three
validate_number_of_arguments 1 'error' 'one two three'

! validate_number_of_arguments 2 'error' one two three
! validate_number_of_arguments 4 'error' one two three
! validate_number_of_arguments 3 'error' 'one two three'

# vim: set filetype=sh fileformat=unix nowrap:
