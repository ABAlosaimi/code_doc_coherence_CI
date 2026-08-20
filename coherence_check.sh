#!/bin/bash

# Usage: ./coherence_check.sh <doc_source_url> <git_diff_output_file>
# Exit code: 0 = all changes documented, 1 = undocumented changes found

DOC_SOURCE=$1
DIFF_FILE=$2

curl -sS "$DOC_SOURCE" > doc.txt

# Extract added lines from diff into a patterns file                                                                                                                                                                                                                
grep '^\+' "$DIFF_FILE" | sed 's/^\+//' > new_changes.txt
                                                                                                                                                                                                                                                                      
  echo "=== Checking changes against doc ==="                                                                                                                                                                                                                       
  if ! grep -qf new_changes.txt doc.txt; then                                                                                                                                                                                                                         
      echo "NOT DOCUMENTED: check out your code-documentation coherence in your new added changes"                                                                                                                                                                                                                                         
      exit 1
  else
      echo "COVERED"
      exit 0
  fi 