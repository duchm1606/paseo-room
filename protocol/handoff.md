# Handoff — moving state and authority to a successor owner or context

> Read by the Lead (owner transitions inside its project) and by the
> Supervisor (Lead replacement under a human mandate). Peers never read
> this file; a Peer only ever produces a handback (`handback.md`).
> Agents produce the packet themselves — there is no skill for it.

## Vocabulary

- **Handback** — a Peer returns its lease to the Lead with evidence
  (`handback.md`). Upward. Ends an assignment.
- **Handoff** — structured transfer of state *and* authority to a new
  owner or a fresh context. Sideways, to a successor. The authority to
  replace a Lead comes from the human; the packet goes to the successor.

## Compact, branch, or hand off?

| Situation | Action | Who |
|---|---|---|
| Context heavy, same owner, same objective, mental model still linear | **compact** | the owner itself |
| A large new dependency appears mid-line (e.g. authorization work discovers there is no authentication) | **do not cram it in** — a separate owner (Peer, or a second Lead for a real project branch) takes the branch, hands back, the main Lead continues | Lead |
| Owner changes; role/disposition changes; context is full of false starts; a new provider/model needs a clean room | **handoff** with a packet | Lead (for Peers), Supervisor (for a Lead) |
| Lead cannot recover | **Lead replacement** — human mandate, break-before-make, receipt | Human decides, Supervisor executes |

"Context is full" alone is not a handoff trigger. Fresh session for
independence, compact for continuity. A fork is not a clean room.

## The packet

The packet is the successor's first prompt (so it lives in the session
log, like every other ruling). Never "read the old transcript and
continue": that moves the sorting cost and the old framing noise onto
the successor. Separate stable decisions from live facts the successor
must re-read (provider IDs, daemon state, active owners) and stamp
live facts with `verified_at`.

```text
HANDOFF
From / To:
Authority transferred:
Authority explicitly retained:
Objective and current state:
Stable decisions (and who closed them):
Candidate / artifacts (exact identity):
Active agents / scripts / writers (verified_at):
Checks and exact results:
Open questions / blockers:
Known failed approaches and their mechanism (do not repeat):
Next permitted action:
Stop / escalation conditions:
```

A Peer-to-Peer handoff may collapse to: objective and current state,
stable facts, decisions and owner, candidate, verification performed,
open questions and risks, exact next authority, do-not-repeat. Owned
scope, authority, and do-not-repeat are never implicit.

## Break-before-make

Replacing the owner of a moving scope: checkpoint and revoke the old
owner **before** activating the new one. Two leases on one scope "for
a few minutes, to be safe" is split-brain.

Lead replacement, in order:

1. freeze new delegation;
2. take a checkpoint from the old Lead if it can still answer;
3. revoke the old binding (archive the seat);
4. create the new Lead with the packet and the unresolved state;
5. reconcile the agents and artifacts that still exist;
6. only then re-enable writes.

If you cannot prove the old binding is revoked, do not activate a new
writer on the same scope.

```text
LEAD REPLACEMENT RECEIPT
Human recovery mandate:
Old Lead binding revoked at:
Old Lead checkpoint:
Unresolved work / agents:
New Lead binding activated at:
Reconciliation result:
Writes re-enabled at:
```

The receipt is the one durable record: the Supervisor appends it to
`SUPERVISOR_NOTEBOOK.md` (or the project's issue tracker when the repo
protocol names one). Everything else stays in session logs.

## Smells

- Handoff as long as a transcript → the stable state was never
  structured into an artifact.
- A successor re-deciding something the packet lists as closed → the
  packet did not say who closed it.
- A successor retrying a known dead end → do-not-repeat was empty.
- Two seats reporting `working` on one scope after a transition →
  break-before-make was skipped.
