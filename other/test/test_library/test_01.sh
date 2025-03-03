#!/usr/bin/env bash

# Halt on error.
set -euo pipefail

source "${REFERENCE_DIR}/usr/local/lib/git_delete_stale_branches/git_delete_stale_branches"

validate_number_of_arguments 3 one two three
validate_number_of_arguments 1 'one two three'

! validate_number_of_arguments 2 one two three
! validate_number_of_arguments 4 one two three
! validate_number_of_arguments 3 'one two three'

function function_test_example_sum() {
    validate_number_of_arguments 2 ${@} || return $?
    local a=${1}
    local b=${2}
    echo $((a + b))
}

(($(function_test_example_sum 1 2) == 3))
(($(function_test_example_sum 57 2) == 59))

! function_test_example_sum 1

{
    # These generate error messages.
    ! (($(function_test_example_sum 1 2 3) == 3))
    ! (($(function_test_example_sum 1) == 3))
} &> /dev/null

# vim: set filetype=sh fileformat=unix nowrap:
