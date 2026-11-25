# Dev Log

One entry per working session, written at the end of it. The log records what
happened and why — decisions taken, things tried that did not work, and the
state the next session inherits. It is the *reasoning* companion to `git log`,
not a replacement: commits say what changed, these say why.

**This directory is public and is read by people evaluating the work.** An entry
is a technical record, not a diary. Accuracy about *who did what* is not a
stylistic preference — it is the difference between evidence and noise.

The rules below are clause-and-effect's dev-log rules, which agent-guards' hooks
were built to enforce, adapted to this repository. Issue numbers written
`clause-and-effect#<n>` are that repository's issues.

## Voice and attribution

Sessions here are worked jointly by a human engineer and an AI assistant. An
entry that blurs the two is worse than useless: it hands the assistant's errors
to the engineer and deletes the engineer's catches, which are the most valuable
thing in the record.

- **Never write a bare "I".** There is no single narrator. Name the agent:
  *"the assistant"* and *"Bertan"* (or *"the engineer"*).
- **Passive voice is correct when the agent carries no information** — facts
  about the system. *"The suite passed 8,510 checks."* Most of an entry should
  read this way.
- **Active voice with a named agent is required when attribution carries
  information** — decisions, errors, corrections, and anything a reader would
  otherwise misassign.
- **Never use passive to soften an error.** *"An error was made"* records
  nothing. Say who, and what the reasoning was that produced it.

## Register

- **Lead with the finding, not the chronology.** Sequence only where causality
  depends on it.
- No suspense, no reveals, no exclamation. A reader skimming for the state of
  the system should get it from the headings.
- Section titles state findings, not events.

## Conventions

- File name: `devlog_YYYY-MM-DD_SESSION-NAME.md`, where `SESSION-NAME` is the
  session name of the agent writing the dev-log.
- The name is never a number counted from the entries that already exist. A
  worktree branch sees only the dev branch and itself, so two branches writing
  on the same day count to the same number, and an entry cannot be renamed
  once it exists (clause-and-effect#157).
- If the agent does not know its session name, or it is in doubt, it should call
  the `ListAgents` function to see its session name.
- A dev-log entry should start with date and time of the entry. Open with
  branch, commit range, and how far ahead of its root branch the current branch
  ended up.
- If the dev-log file that the agent is trying to write already exists,
  the agent should append a new dev-log entry to the file with a date and time.
- An append is made with `>>` from Bash, and an entry that exists is never
  edited with the Edit or Write tool, except to correct the session segment of
  its heading onto its file name (clause-and-effect#177, its ADR 0003).
  `append-only-docs.sh` reads a heredoc's text as part of the command, so a
  heredoc append whose prose reads as a command that rewrites an entry can be
  refused: a `sed -i` anywhere in the text, for example, or an `rm` or an `mv`
  followed on its line by a path under this directory (clause-and-effect#237),
  or a `>` followed on its line by such a path (clause-and-effect#176). Write
  the text to a scratch file with the Write tool first, and append it with
  `cat <file> >> <entry>`.
- An entry's first line is its heading. It carries the date its file name
  carries, and when it names a session it names the one the file is named for;
  it may name none (clause-and-effect#162). An entry exists from its first
  write, so write the heading right the first time.
- Written for technical readers who know the codebase. Prefer measured numbers
  and commit SHAs over recollection — and say which figures were measured versus
  recalled.
- Record dead ends and mistakes, not just the path that worked. Attribute each
  one.
- Close with what is still open and what the next session should pick up.
- Do not add the entries in this file.

## What enforces these rules here, and what does not yet

- **No hook guards this repository's own sessions yet.** Which copy of the
  hooks should (the working tree, or a tagged release) is an open decision.
  Until then the rules above are followed, not enforced.
- **This suite does not read these entries.** `hooks/check-hooks.sh` holds the
  hooks to the frozen clause-and-effect documents in `hooks/fixtures/host/`,
  never to this directory. Checking a repository's own dev-log (heading against
  file name, and the rest) is the job of the per-repository config check,
  which does not exist yet.
- **The protected folders are still clause-and-effect's**, hard-coded in the
  two append-only hooks: `docs/dev-log/`, `docs/lessons-learned/` and
  `docs/eval-reports/`. This repository has only the first. Making each
  repository declare its own is the config extraction.
