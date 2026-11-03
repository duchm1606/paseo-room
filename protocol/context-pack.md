# Context pack — superseded

The agent creation contract is now `assignment.md` in this directory.
This file stays only so older references resolve; do not fill the old
skeleton. Field mapping for anyone updating an old brief:

| old field | new field |
|---|---|
| Project / workspace, Task | `ASSIGNMENT <id>`, `project:` |
| Disposition | `disposition:` |
| Authority source, Acceptance owner | dropped — the assignee is told neither |
| Workspace, Existing active owner/writer | `SCOPE.write`, `SCOPE.held` |
| Candidate / snapshot | `FACTS` |
| Objective | `OUTCOME` |
| Success condition | `ACCEPTANCE` |
| Stop condition | `SCOPE.stop` |
| Owned, Excluded, Mutation | `SCOPE.write`, `OUT OF SCOPE`, `SCOPE.write` |
| External effects | `SCOPE.external` |
| Stable facts | `FACTS` |
| Unverified assumptions | `UNKNOWN` |
| Do not inherit | `DECIDED` (ruled-out approaches with why) |
| Verification | `ACCEPTANCE` |
| Escalate | `RESPOND.kinds` |
| Handback | `RESPOND.terminal` |

The rule that survives unchanged: just enough — never the full
history, never hidden constraints, never a pre-made answer. The
assignee sees only the filled instance, never this file.
