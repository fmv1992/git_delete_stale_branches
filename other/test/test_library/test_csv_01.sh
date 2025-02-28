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

csv_invalid_01="./other/test/test_library/csv_invalid_01.csv"
csv_invalid_02="./other/test/test_library/csv_invalid_02.csv"

# Should return 2 for valid 2-field CSV.
! _csv_n_distinct_fields "${csv_invalid_01}"
[[ "$(_csv_n_distinct_fields "${csv_invalid_01}")" == 'mixed' ]]

[[ "$(_csv_n_distinct_fields "${csv_invalid_02}")" == '3' ]]

# if [[ ${result} != "2" ]]; then
#     echo "Expected 2 fields for csv_valid_01.csv but got: ${result}" >&2
#     exit 1
# fi
#
# # Should return 3 for valid 3-field CSV
# result=$(_csv_n_distinct_fields "${SCRIPT_DIR}/csv_valid_02.csv")
# if [[ ${result} != "3" ]]; then
#     echo "Expected 3 fields for csv_valid_02.csv but got: ${result}" >&2
#     exit 1
# fi
#
# # Should return "mixed" for invalid mixed-field CSV
# result=$(_csv_n_distinct_fields "${SCRIPT_DIR}/csv_invalid_01.csv")
# if [[ ${result} != "mixed" ]]; then
#     echo "Expected 'mixed' for csv_invalid_01.csv but got: ${result}" >&2
#     exit 1
# fi
#
# # Test is_valid_simple_csv function
# echo "Testing is_valid_simple_csv..."
#
# # Valid 2-field CSV should pass
# assert_success is_valid_simple_csv "${SCRIPT_DIR}/csv_valid_01.csv"
#
# # Valid 3-field CSV should pass
# assert_success is_valid_simple_csv "${SCRIPT_DIR}/csv_valid_02.csv"
#
# # Invalid mixed-field CSV should fail
# assert_failure is_valid_simple_csv "${SCRIPT_DIR}/csv_invalid_01.csv"
#
# # Invalid 3-field CSV (missing header) should fail
# assert_failure is_valid_simple_csv "${SCRIPT_DIR}/csv_invalid_02.csv"
#
# # Test argument validation
# echo "Testing argument validation..."
#
# # Should fail with no arguments
# assert_failure _csv_n_distinct_fields
# assert_failure is_valid_simple_csv
#
# # Should fail with non-existent file
# assert_failure _csv_n_distinct_fields "nonexistent.csv"
# assert_failure is_valid_simple_csv "nonexistent.csv"
#
# echo "All tests passed!"
# exit 0

# vim: set filetype=sh fileformat=unix nowrap:
