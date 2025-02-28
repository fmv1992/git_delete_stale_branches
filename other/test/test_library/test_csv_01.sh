#!/usr/bin/env bash

# Halt on error.
set -euo pipefail

source "${REFERENCE_DIR}/usr/local/lib/git_delete_stale_branches/git_delete_stale_branches"

# * `./other/test/test_library/csv_invalid_01.csv`: This is wrong by virtue of
# having records with 2 and 3 fields.
#
# * `./other/test/test_library/csv_invalid_02.csv`: This is a 3-field CSV file
# without the proper headers.
#
# * `./other/test/test_library/csv_valid_02.csv`: This is a valid 3-field CSV
# file.
#
# * `./other/test/test_library/csv_valid_01.csv`: This is a 2-field CSV file
# without headers. It should be valid.

# vim: set filetype=sh fileformat=unix nowrap:
