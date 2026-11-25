# Fixtures

`host/` is the project the hooks are run against: test material for the check suite, not agent-guards' own documents.

At each run the suite copies `host/` to a temporary directory, makes it a git repository with one commit, and hands it to the hooks as the project root (`REPO_ROOT`, passed on as `CLAUDE_PROJECT_DIR`). Its files stand where clause-and-effect's real files stood when the suite lived in that repository, under the same names, because the checks name them. Copied from clause-and-effect `e59a02d` and cut down to what the checks read: whether a file exists, and a dev-log entry's first line.

The suite's own repository (agent-guards) is `SUITE_REPO`: the repository whose refs no `dev-NN` check may read (#144).
