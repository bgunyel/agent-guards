# Fixtures

`host/` is the project the hooks are run against: test material for the check suite, not agent-guards' own documents.

At each run the suite copies `host/` to a temporary directory, makes it a git repository with one commit, and hands it to the hooks as the project root (`REPO_ROOT`, passed on as `CLAUDE_PROJECT_DIR`). Its files stand where clause-and-effect's real files stood when the suite lived in that repository, under the same names, because the checks name them. Two kinds of file, both copied from clause-and-effect `e59a02d`:

- **Cut down** to what the checks read (whether the file exists): `docs/research/non-openrouter-response-bodies.md` and `src/config.py`.
- **Frozen whole** (step 2g): `CLAUDE.md`, `CONTEXT.md`, `docs/dev-log/` (the README and every entry) and `tests/test_docs_directory_naming.py`. The checks hold the hooks to these documents: the hooks' block messages cite them, and the dev-log checks read the README's rules and every real entry. They are a snapshot, not kept in step with clause-and-effect; agent-guards' own document for what the hooks cite replaces them at step 3, and these checks are redesigned against it then.

The suite's own repository (agent-guards) is `SUITE_REPO`: the repository whose refs no `dev-NN` check may read (#144). A requirement's `verify: tests/<file>.py` names a test of the host project, so it resolves against `REPO_ROOT`, not here.
