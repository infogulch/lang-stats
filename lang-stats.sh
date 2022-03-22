#!/bin/bash

function next_monday() {
    seq 0 6 | xargs -I {} date -d "$1 {} day" +"%u %Y-%m-%d" | sort | head -1 | awk '{print $2}'
}

BRANCH="$(git rev-parse --abbrev-ref HEAD)"

trap "git checkout -f $BRANCH" EXIT

# Find the first commit
# %cI %H format is ISO8601 date followed by commit hash
INITIAL_COMMIT="$(git rev-list --max-parents=0 --format="format:%cI %H" --no-commit-header "$BRANCH" | sort | head -1 | awk '{print $2}')"
INITIAL_COMMIT_DATE="$(git log --format=format:%cI "$INITIAL_COMMIT" | cut -c 1-10)"

STATS_FILE="../weekly-stats.csv"
[ ! -f "$STATS_FILE" ] && echo "date,language,files,lines,code,comments,blanks" > "$STATS_FILE"

# Enumerate every week between the first commit and now
NEXT_DATE="$(next_monday "$INITIAL_COMMIT_DATE")"
while [ "$(($(date +%s) - $(date -d "$DATE" +%s)))" -gt 0 ]
do
    DATE="$NEXT_DATE"
    NEXT_DATE="$(date -d "$DATE 7 days" +"%Y-%m-%d")"

    # skip if stats have already been generated for this period
    [ "$(xsv search -s date "$DATE" "$STATS_FILE" | xsv count)" -gt 0 ] && continue # is xsv really required?

    # skip if commit is the same as the previous commit (i.e. no changes since previous week)
    COMMIT="$(git rev-list --until="$DATE" -1 "$BRANCH")"
    [ "$COMMIT" = "$PREV_COMMIT" ] && continue
    PREV_COMMIT="$COMMIT"

    echo "Calculating stats for $DATE @ $COMMIT"
    git checkout -q "$COMMIT"
    tokei -o json | jq -r -f ../summarize-tokei.jq --arg hello "$DATE" >> "$STATS_FILE"
done

# postprocess data:
#  truncate langs with fewer than a minimum number of lines
#  remove total, add "other" by subtracting the remaining languages numbers from total
