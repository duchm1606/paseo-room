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

# Message taxonomy (peer → Lead)

- `REOPEN_REQUEST` — the issue's premise is wrong (foundation, lifecycle,
  API, ownership); compatibility patches refused.
- `DEPENDENCY_REQUEST` — needs a change outside the granted scope.
- `BLOCKED` — a specific input is missing to proceed.

(A peer may suggest a council inside a `REOPEN_REQUEST`; convening one
is the Lead's call. There is no `COUNCIL_REQUEST` message.)

Every message receives a concrete ruling with its reasons, stated in
the conversation. Session logs are the archive; no record files.
