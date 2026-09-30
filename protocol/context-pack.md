# Context pack — the agent creation contract (Lead → Peer)

Just enough — never the full history, never hidden constraints, never a
pre-made answer. Every significant task brief carries the Demonthorn
creation contract. The Lead fills this template; the Peer only ever
sees the filled instance, never this file.

## Brief skeleton

```text
Project / workspace: <repository / project identity>
Task: <case-slug or issue>
Disposition: <Engineer | Architect | Reviewer | Scout | auditor | advisor>
Authority source: <the Lead seat / issue that grants this lease>
Workspace: <checkout or isolated worktree — required for concurrent writers>
Existing active owner/writer: <none | who, on which scope — never two on one>
Candidate / snapshot: <exact commit or digest when reviewing or building on one>
Objective: <the outcome, as an open goal — not the solution>
Success condition: <observable acceptance>
Stop condition: <when to hand back instead of continuing to mutate>
Owned: <writable scope, e.g. src/save/**, tests/save/**>
Excluded: <explicitly out of scope>
Mutation: <no-write | write-bounded | explicit list>
External effects: <denied | explicit list — commit / push / deploy / send / spend>
Stable facts: <verified, with source>
Unverified assumptions: <stated as claims, never as facts>
Do not inherit: <framings or prior conclusions the peer must not adopt>
Verification: <required checks and artifacts; proof plan below for high-risk work>
Acceptance owner: <Lead | Human>
Escalate: <which premise failures warrant REOPEN / DEPENDENCY / BLOCKED>
Handback: <expected report per handback.md, ending with the terminal sentinel>
```

Add only when they hold a real boundary: tool/call budget, credential
handling, retry condition, deadline / wake event.

Not every line is ceremony for every task — a tiny bounded task may
collapse to five lines (objective, owned scope, mutation + external
effects, evidence, stop). But owned scope, exclusions, mutation and
external-effect boundaries, and the acceptance owner are never
implicit. Brevity does not weaken a lease when the boundary is small.

## Beyond the skeleton (what the filled pack must still convey)

- relevant files or modules — paths to source artifacts, never pasted contents
- real constraints, with no hidden ones
- anti-patterns to avoid, by name (see anti-patterns.md)

## Proof plan (high-risk work — fills the Verification line)

Before the work starts, per claim the handback must support:

```text
Claim:
Owning layer: <source | artifact | installed | live | user journey>
Risk if false:
Smallest discriminating check: <which wrong mechanism would make it fail>
Negative case:
Expected observation:
Acceptance owner:
```

## Voice

Open every pack with the disposition and mutation boundary
("Disposition: Engineer. Owned: …" / "Disposition: Reviewer. Mutation:
no-write."). For
an Engineer disposition: write the prompt as a direct work request;
method and acceptance live in the issue. Never mention
paseo/session/orchestration mechanics.

For a Council seat: neutral brief + explicit method, one separate child
issue per seat, sealed — no leaning conclusions, no visibility into
other seats.
