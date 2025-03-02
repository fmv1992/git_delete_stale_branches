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
# * `./other/test/test_library/csv_valid_01.csv`: This is a 2-field CSV file
# without headers. It should be valid.
#
# * `./other/test/test_library/csv_valid_02.csv`: This is a valid 3-field CSV
# file.
#
# * `./other/test/test_library/csv_valid_03.csv`: This is a 3-field CSV file
# without the proper headers.
#
# * `./other/test/test_library/csv_valid_04.csv`: This is a 3-field CSV file
# without the proper headers.

! print_normalized_csv

csv_invalid_01="./other/test/test_library/csv_invalid_01.csv"
csv_invalid_02="./other/test/test_library/csv_invalid_02.csv"

! print_normalized_csv "${csv_invalid_01}"
! print_normalized_csv "${csv_invalid_02}"

csv_valid_01="./other/test/test_library/csv_valid_01.csv"
csv_valid_02="./other/test/test_library/csv_valid_02.csv"
csv_valid_03="./other/test/test_library/csv_valid_03.csv"
csv_valid_04="./other/test/test_library/csv_valid_04.csv"

print_normalized_csv "${csv_valid_01}"
((0 == $?))
print_normalized_csv "${csv_valid_02}"
((0 == $?))
print_normalized_csv "${csv_valid_03}"
((0 == $?))
print_normalized_csv "${csv_valid_04}"
((0 == $?))

# vim: set filetype=sh fileformat=unix nowrap:
