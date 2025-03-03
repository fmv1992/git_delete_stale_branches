#!/usr/bin/gawk -f
BEGIN {
    three_field_header = "timestamp_delete_if_commit_is_older,branch,timestamp_delete_after"
    two_field_header = "timestamp_delete_if_commit_is_older,branch"
    n_csv_fields = -1
    exit_code = 0
    default_timestamp_delete_after = 0
    # `line_acc` is an array.
}

NR == 1 {
    normalized_input = gensub(/[[:space:]]/, "", "g", $0)
    normalized_three = gensub(/[[:space:]]/, "", "g", three_field_header)
    normalized_two = gensub(/[[:space:]]/, "", "g", two_field_header)
    if (normalized_input == normalized_three) {
        n_csv_fields = 3
        next
    } else if (normalized_input == normalized_two) {
        n_csv_fields = 2
        next
    }
    line_copy = $0
    n_csv_fields = gsub(/,/, "", line_copy) + 1
    if (n_csv_fields == 2) {
        # Do nothing here.
    }
    else if (n_csv_fields == 3) {
        # This is a 3-field CSV but without the header. This is an error.
        print("ERROR: Missing header in 3-field CSV: " $0) > "/dev/stderr"
        exit_code = 1
        exit exit_code
    } else {
        print("ERROR: This edge case is not supported.") > "/dev/stderr"
        exit_code = 1
        exit exit_code
    }
}

exit_code == 0 {
    # Verify that all records have the correct number of fields.
    line_copy = $0
    n_csv_fields_this_line = gsub(/,/, "", line_copy) + 1
    if (n_csv_fields_this_line != n_csv_fields) {
        print("ERROR: Invalid record: \302\253" $0 "\302\273") > "/dev/stderr"
        exit_code = 1
        exit exit_code
    }
    if (line_is_valid($0)) {
        if (n_csv_fields == 2) {
            line_acc[NR] = sprintf("%s,%s," trim(default_timestamp_delete_after) "\n", trim($1), trim($2))
        } else {
            line_acc[NR] = sprintf("%s,%s,%s\n", trim($1), trim($2), trim($3))
        }
    } else {
        print("ERROR: Invalid record: \302\253" $0 "\302\273") > "/dev/stderr"
        exit_code = 1
        exit exit_code
    }
}

END {
    if (exit_code == 0) {
        for (i in line_acc) {
            printf line_acc[i]
        }
    } else {
        # This is weird:
        #
        # ```
        # exit exit_code
        # ```
        #
        # Ends with `0` exit code.
        exit 1
    }
}


function line_is_valid(line)
{
    # The first field should be an integer.
    if ($1 !~ /^[[:space:]]*[0-9]+[[:space:]]*$/) {
        if ($2 ~ /^[[:space:]]*$/) {
            if (n_csv_fields == 3) {
                if ($3 !~ /^[[:space:]]*[0-9]+[[:space:]]*$/) {
                    return 0
                } else {
                    return 1
                }
            } else if (n_csv_fields == 2) {
                return 0
            } else {
                return 1
            }
        }
    }
    return 1
}

function trim(s)
{
    return gensub(/^[ \t\r\n]+|[ \t\r\n]+$/, "", "g", s)
}
