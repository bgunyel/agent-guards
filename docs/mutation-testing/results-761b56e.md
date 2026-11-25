# Mutation pass at `761b56e`

The whole registry of `hooks/mutate-hooks.sh` (191 rows) run against
`761b56e`, the first commit at which the suite passes in agent-guards with
nothing read from outside it (8,510 checks). This is the comparison with
clause-and-effect, where the hooks were copied from at `e59a02d`: each row
declares the outcome it is expected to have, so a row that reports it agrees
with clause-and-effect's registry, and one that does not is a disagreement to
explain. Procedure: [README.md](README.md).

## How a chunk is judged

Two questions, because they can answer differently:

- **Matches the registry**: every row in the chunk reported the outcome the
  registry declares for it, almost always `caught` (the planted defect turned
  the suite red). This is the harness's own verdict, the line
  `EVERY MUTATION REPORTED WHAT THE REGISTRY EXPECTS`, and what
  `out/mutation/summary.txt` records as `agrees` or `DISAGREES`.
- **Matches clause-and-effect**: every row reported what it reports in
  clause-and-effect at `e59a02d`. A chunk that matches the registry matches
  clause-and-effect too. Each row of a chunk that does not is run again in a
  throwaway clone of clause-and-effect at `e59a02d`, and the chunk matches if
  each reports the same there.

The carry is proven when every chunk **matches clause-and-effect**. Each row
that matches clause-and-effect but not the registry is a defect agent-guards
inherited, listed under Disagreements, and fixed after the carry, while the
guards are frozen.

## Chunks

| Chunk | Rows | Run (2026-11-25 unless stated) | Matches the registry | Matches clause-and-effect |
|---|---|---|---|---|
| subset | 11 (the rows on `append-only-docs-edit.sh` and `report-stale-branches.sh`) | 10:00 → 11:31 | yes: all 11 caught | yes |
| 00 | 7 | 11:42 → 12:31 | no: 6 caught; `bracket-opens-a-collating-element` did not complete | yes: that row does not complete there either |
| 01–25 | 173 | running | | |

## Disagreements

### `bracket-opens-a-collating-element` (chunk 00)

- Declared: `caught` (GH-134). Got: `did-not-complete`. The suite exited 1
  before printing a matrix, with `lib/command-scan.sh`'s load-time message
  "CS_WRAPPER_RE does not compile, …".
- The row edits `CS_SEPARATORS` so the bracket expression built from it does
  not compile. The harness's own notes record the last run of this row on
  2026-09-20, when the guard GH-134.1 added withdrew `cs_split` and the suite
  completed with 1,564 checks red. Today the same guard stops the suite at
  load, and a run that prints no matrix is never read as `caught`.
- **clause-and-effect at `e59a02d` reports the same** (checked 2026-11-25,
  12:33 → 12:42, a throwaway clone, the row alone): baseline green over 278
  requirements, then `did-not-complete` with the same message. So the row's
  declared outcome went stale in clause-and-effect, after its last run, and
  agent-guards carried it faithfully. It is not a defect of the move.
- The guards are frozen during the carry, so the row is not changed here. To
  fix after it: decide what the row should declare now that the guard stops
  the suite at load (and whether "the suite refuses to run" should count as
  the defect being caught), and re-run it.
