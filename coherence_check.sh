#!/bin/bash

# Usage: ./coherence_check.sh <doc_source_url> <git_diff_output_file>
# Exit code: 0 = all changes documented, 1 = undocumented changes found

DIFF_FILE=$(cat diff_output.txt)

if ! curl -fsSo doc.txt "$DOC_SOURCE_URL"; then
  echo "Documentation not found or there is a server-side issue"
  exit 1
fi

less doc.txt

# Extract new lines added in the diff
grep '^\+' "$DIFF_FILE" | sed 's/^\+//' > new_changes.txt

less new_changes.txt

echo "=== Checking changes against doc ==="
if ! grep -qf new_changes.txt doc.txt; then
    echo "UNCOVERED FEATURE: your feature is not mentioned in any doc file, make sure you document it first then push to the branch"

    if [ "$DATA_PIPELINE_ENABLED" = "true" ]; then
        CI_STATUS=false python3 snowflake_pipeline.py
        exit $?
    fi

    exit 1
fi

echo "COVERED"
echo "=== Checking changes against doc end ==="

if [ "$DATA_PIPELINE_ENABLED" = "true" ]; then
    CI_STATUS=true python3 snowflake_pipeline.py
    exit $?
fi

exit 0
