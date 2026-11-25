# Mutation testing

`hooks/mutate-hooks.sh` re-runs the claims the check suite makes about itself:
each row of its registry plants one defect in a copy of the hooks (or of a
file the suite reads), runs `hooks/check-hooks.sh` against that copy, and says
whether the suite caught it. Each row declares the outcome it is expected to
have — `caught`, or for its two self-tests `survived` and `did-not-apply` — so
a pass is judged row by row against the registry, not against another
repository's run. Its own header says what a pass is evidence of, and what it
cannot reach.

`bash hooks/mutate-hooks.sh --list` applies every row's edit in a sandbox,
runs no suite, and prints the registry with the cost of a whole pass.

## A whole pass, in chunks

A whole pass is one suite run per row plus a baseline: 191 runs at `761b56e`,
at about 7.6 min a run on the development laptop (measured 2026-11-25), so
about a day. `scripts/run-mutation-chunks.sh` runs it in chunks of 7 rows,
about an hour each, one after another:

    bash scripts/run-mutation-chunks.sh <commit>          every chunk not yet done
    bash scripts/run-mutation-chunks.sh <commit> 07       one chunk

Each chunk pays its own baseline run, because the harness believes no row
before an unmutated copy has passed in the same invocation. One chunk at a time:
the machine has six cores, a suite run takes a little over one, and the harness
has measured runs three times slower when several share a machine.

## Where things are kept

| What | Where | Kept by |
|---|---|---|
| The commit the pass is for | `out/mutation/commit` | disk only (git-ignored) |
| A clone checked out at that commit, never edited | `out/mutation/clone/` | disk only |
| The row ids of each chunk | `out/mutation/chunks/chunk-NN.txt` | disk only |
| The harness's output for each chunk | `out/mutation/logs/chunk-NN.log` | disk only |
| One line per finished chunk: agrees, or DISAGREES, with the registry | `out/mutation/summary.txt` | disk only |
| **The record of a pass**: each chunk judged against the registry and against clause-and-effect | `docs/mutation-testing/results-<commit>.md` | **git** |

Nothing a pass needs is under `/tmp`: the harness's mutated copies are, and
they are thrown away after every run.

## Stopping and resuming

A chunk counts as done only when its log holds the harness's success verdict
(`EVERY MUTATION REPORTED WHAT THE REGISTRY EXPECTS`). A shutdown loses the
chunk in progress, whose log has no verdict; the next run of the script starts
that chunk again and skips every chunk that already agrees. A chunk that
disagreed is run again too, and its line stays in `summary.txt`. Nothing
restarts the script after a reboot; run it again by hand.
