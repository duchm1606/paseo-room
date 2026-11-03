# State contract

| State | Meaning |
|---|---|
| `working` | Executing the assigned task |
| `blocked` | Needs information or a resource — includes the exact missing input |
| `done` | Deliverable complete — **signal for the Lead to collect results now** |
| `idle` | No task assigned |
| `stopped` | Session stopped |
| `error` | Cannot continue |

Hard rule: `done` is not `idle`. A Lead waiting for `idle` while the worker
reports `done` is a workflow freeze (Herdr curriculum, Failure 6). Track by
events, never by polling.

# Response kinds (assignee → assigning authority)

Authoritative set, per `assignment.md`. Every response names the
assignment id and the revision it was built to.

- `RESULT` — the candidate and its proof; complete, missing, failed,
  and unverified kept apart.
- `CHALLENGE` — a recorded choice or premise is disputed with evidence;
  the assignee continues independent work meanwhile.
- `DECISION_REQUEST` — a decision outside the assignee's authority is
  needed: a missing prerequisite, another scope, a changed contract.
- `BLOCKED` — no safe in-scope progress remains.

Transition mapping for responses still written in the old vocabulary
(treat them as the new kind; do not send them back for rewording):

| old | read as |
|---|---|
| `REOPEN_REQUEST` | `CHALLENGE` |
| `DEPENDENCY_REQUEST` | `DECISION_REQUEST` |
| `BLOCKED` | `BLOCKED` |
| handback with CONFIRM / PARTIAL | `RESULT` |

A legacy response carries no revision. Attach one only when the
assignment's history shows exactly one revision was in force when the
response was produced; otherwise reissue the current revision asking
which one the response was built to. Never guess a number.

(An assignee may suggest a council inside a `CHALLENGE`; convening one
is the assigning authority's call. There is no `COUNCIL_REQUEST`.)

Every message receives a concrete ruling with its reasons, stated in
the conversation. Session logs are the archive; no record files.
