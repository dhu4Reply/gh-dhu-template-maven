#!/bin/bash

# Find files with merge conflicts
conflict_files=$(git grep -l '^<<<<<<<')

if [ -z "$conflict_files" ]; then
  echo "No merge conflicts found."
  exit 0
fi

issue_title="Merge Conflicts Detected in Repository"
issue_body="### ⚠️ Merge conflicts have been detected in the following files:

"

for file in $conflict_files; do
  conflict_block=$(awk '/^<<<<<<< /, /^>>>>>>> /' "$file")
  if [ -n "$conflict_block" ]; then
    issue_body+="#### File: $file

```diff
$conflict_block
```
"
  else
    issue_body+="#### File: $file

(No conflict block found)
"
  fi
done

issue_body+="
Please resolve these conflicts as soon as possible.
"

# Create the issue using GitHub CLI
gh issue create --title "$issue_title" --body "$issue_body"
