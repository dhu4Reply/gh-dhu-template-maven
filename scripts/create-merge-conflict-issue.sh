#!/usr/bin/env bash
set -euo pipefail

# 1) Files mit Konflikten finden
conflict_files=$(git grep -l '^<<<<<<< ')
if [ -z "$conflict_files" ]; then
  echo "No merge conflicts found."
  exit 0
fi

# 2) Issue-Titel
issue_title="Merge Conflicts Detected in Repository"

# 3) Temporäre Datei für den Body anlegen
body_file=$(mktemp)
trap 'rm -f "$body_file"' EXIT

# 4) Header schreiben
{
  echo "### ⚠️ Merge conflicts have been detected in the following files:"
  echo
} >> "$body_file"

# 5) Pro File den Conflict-Block anhängen
for file in $conflict_files; do
  echo "#### File: $file" >> "$body_file"
  echo >> "$body_file"
  echo '```diff'       >> "$body_file"
  awk '/^<<<<<<< /, /^>>>>>>> /' "$file" >> "$body_file"
  echo '```'            >> "$body_file"
  echo                 >> "$body_file"
done

# 6) Footer schreiben
{
  echo "Please resolve these conflicts as soon as possible."
  echo
} >> "$body_file"

# 7) Issue erstellen
gh issue create \
  --title "$issue_title" \
  --body-file "$body_file"

echo "Issue created."