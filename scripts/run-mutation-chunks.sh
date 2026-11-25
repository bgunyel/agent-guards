#!/bin/bash
# Runs the mutation registry (hooks/mutate-hooks.sh) in chunks, one after
# another, against a clone frozen at one commit. A whole-registry pass is
# about a day of suite runs; chunks of 7 rows take about an hour each, and a
# pass can be stopped and resumed losing only the chunk in progress.
# The procedure and where results are kept: docs/mutation-testing/README.md.
#
#   bash scripts/run-mutation-chunks.sh <commit>          every chunk not yet done
#   bash scripts/run-mutation-chunks.sh <commit> 03 04    only those chunks
#
# Everything a pass writes is under out/mutation/ (git-ignored):
#   commit          the commit the pass is for; a pass for another commit is
#                   refused until out/mutation/ is moved aside
#   clone/          a clone checked out at that commit, never edited
#   chunks/         chunk-NN.txt, the row ids of each chunk, made once from
#                   `mutate-hooks.sh --list` when the directory is empty
#   logs/           chunk-NN.log, mutate-hooks.sh's output for each chunk
#   summary.txt     one line per finished chunk: agrees, or DISAGREES
#
# A chunk is done only when its log holds the harness's success verdict, so a
# chunk cut short (a shutdown, a kill) has none and runs again from its start,
# and so does one that disagreed. Each chunk pays its own baseline run: the
# harness believes no row before an unmutated copy has passed in the same
# invocation.
set -u
CHUNK_ROWS=7
OK='EVERY MUTATION REPORTED WHAT THE REGISTRY EXPECTS'
REPO=$(cd "$(dirname "$0")/.." && pwd)
WORK="$REPO/out/mutation"
CLONE="$WORK/clone"

[ $# -ge 1 ] || { sed -n '9,10p' "$0" | sed 's/^# *//' >&2; exit 2; }
COMMIT=$(git -C "$REPO" rev-parse --short "$1^{commit}" 2>/dev/null) || {
  echo "$1 is not a commit in $REPO" >&2; exit 2; }
shift

mkdir -p "$WORK/chunks" "$WORK/logs" || exit 1
if [ -f "$WORK/commit" ]; then
  [ "$(cat "$WORK/commit")" = "$COMMIT" ] || {
    echo "out/mutation/ holds a pass for $(cat "$WORK/commit"); move it aside to start one for $COMMIT" >&2
    exit 1; }
else
  echo "$COMMIT" > "$WORK/commit"
fi

if [ ! -d "$CLONE/.git" ]; then
  git clone -q "$REPO" "$CLONE" && git -C "$CLONE" checkout -q "$COMMIT" || exit 1
fi
[ "$(git -C "$CLONE" rev-parse --short HEAD)" = "$COMMIT" ] \
  && [ -z "$(git -C "$CLONE" status --porcelain)" ] || {
  echo "$CLONE is not a clean checkout of $COMMIT; remove it and run again" >&2
  exit 1; }

if [ -z "$(ls "$WORK/chunks")" ]; then
  ( cd "$CLONE" && bash hooks/mutate-hooks.sh --list ) > "$WORK/list.txt" 2>&1 || {
    echo "mutate-hooks.sh --list failed; see $WORK/list.txt" >&2; exit 1; }
  awk 'NF >= 5 && $3 ~ /^(caught|survived|did-not-apply)$/ { print $1 }' "$WORK/list.txt" \
    | split -l "$CHUNK_ROWS" -d -a 2 --additional-suffix=.txt - "$WORK/chunks/chunk-"
  [ -n "$(ls "$WORK/chunks")" ] || { echo "no registry rows were read from --list" >&2; exit 1; }
fi

if [ $# -gt 0 ]; then
  set -- $(printf "$WORK/chunks/chunk-%s.txt " "$@")
else
  set -- "$WORK"/chunks/chunk-*.txt
fi
for chunk in "$@"; do
  [ -f "$chunk" ] || { echo "no such chunk: $chunk" >&2; continue; }
  n=$(basename "$chunk" .txt)
  log="$WORK/logs/$n.log"
  if [ -f "$log" ] && grep -qF "$OK" "$log"; then
    echo "$n: done before, skipped"
    continue
  fi
  start=$(date '+%F %H:%M')
  ( cd "$CLONE" && bash hooks/mutate-hooks.sh -v $(cat "$chunk") ) > "$log" 2>&1
  rc=$?
  if grep -qF "$OK" "$log"; then verdict="agrees"; else verdict="DISAGREES (rc=$rc), see $log"; fi
  line="$n  $start -> $(date '+%H:%M')  $(wc -l < "$chunk") rows  $verdict"
  echo "$line"
  echo "$line" >> "$WORK/summary.txt"
done
