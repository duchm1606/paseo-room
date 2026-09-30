# Workspace Protocol (template)

> Copy this file to a repository root as `WORKSPACE_PROTOCOL.md` and
> fill it in for that repo. The Human/project owner owns the file; the
> Lead must read it in full before orchestrating; Peers never read it
> (the Lead excerpts relevant constraints into briefs); the Supervisor
> reads it only when assigned to audit or update it.

## Status

- owner: <Human/project owner>
- version: 1
- last_reviewed: YYYY-MM-DD
- applies_to: <repository root>
- readers: Lead; Supervisor only when assigned to audit

## Project characteristics

- criticality:
- dominant risks:
- expensive-to-reverse decisions:
- external side effects:

## Authority

- Lead may decide:
- Human must decide:
- prohibited without explicit authority:

## Issue tracker

Optional. Name the tracker this repository uses, or write `none`.

- tracker: <GitHub Issues | none>
- who may create or close issues:

With `none`, the Lead's brief is the only record of scope, and the closing
report is the only record of outcome. Never let a seat invent tracker state:
an issue that was never read is `UNKNOWN`, not open or closed.

## Task classes

### Tiny / bounded

- one Engineer with a thin brief (the Lead never implements)
- targeted verification; Lead counter-review on handback
- independent Reviewer optional

### Cross-module / lifecycle-sensitive

- one read-only Architect before implementation
- one Engineer with isolated write scope
- one independent Reviewer on a stable candidate

### Architecture lock-in

- sealed Architect and Reviewer mandates ("dual design / dual review":
  two independent seats across model tiers or providers, one frozen
  candidate, distinct mandates — see protocol/council.md)
- review runs three lanes: the two dual-review seats plus one OCR
  delegation lane on the same frozen candidate; the OCR lane produces
  rule-based evidence and never replaces the macro
  (architectural/lifecycle) review lanes
  - staff the OCR lane by MODEL, not by provider. On this host it is
    `codex-peer/gpt-5.6-luna` at max effort; a dedicated
    `codex-review` provider was deleted 2026-09-12. Instantiate this
    field against the daemon's current provider table rather than
    copying the route forward.
- compare alternatives and reversal conditions
- Lead issues one binding project verdict
- Human decides irreversible product/cost trade-offs

## Ownership and workspaces

- one writer per moving scope
- concurrent writers require separate worktrees
- no overlapping ownership
- review only a stable candidate
- define handback and integration owner

## Routing

- pin the per-role routing for THIS repo (provider / model / effort /
  access mode), e.g. "Lead: <...>; implementation and
  review-remediation owners: <...> in full-access; review seats:
  <...>" — the Lead must not re-derive routing per task
- inspect currently available providers/models
- bounded familiar work: coding model, medium effort
- lifecycle/ownership work: strong reasoning model
- monitoring: economical model when risk permits

## Brief discipline

- every writable-owner brief must explicitly forbid stopping to offer
  the Lead a menu of implementation options; the owner exercises its
  own judgment inside its scope. A genuinely cross-boundary decision
  is a single short, concrete yes/no approval question — never an
  option-selection ritual
- council and review briefs are short and sufficient, never reveal or
  hint at the Lead's preferred answer, and never pre-solve; for
  reviews, do not narrow the review dimensions or otherwise anchor the
  seats — give the stable artifact, governing constraints, and the
  open question

## Context budget

- after a long-context owner hands back, if its context consumption
  exceeds ~45% of the model window, compact that owner before further
  work or start a fresh owner when clean context is the safer
  continuation; preserve ownership truth and durable handback
  artifacts across either transition — never silently continue a
  context-heavy owner

## Ultra-review gate

- ultra-review runs outside the room (human session), never as a seat
- do not run it after every slice or remediation; default is one run
  at plan closure
- mid-plan runs only at a stable checkpoint that completes an
  end-to-end capability, freezes a dependency foundation, or crosses a
  hard-to-reverse wire/storage/migration/ownership/security boundary
- never on unfinished composition, pending validation, or known later
  work
- after findings: focused Peer follow-up through the Lead; re-run only
  for a materially new convergence claim
- brief active peers only at handback, never by interrupting them

## Escalation

- REOPEN_REQUEST: foundation/premise fails
- DEPENDENCY_REQUEST: another owner/API/scope is required
- BLOCKED: authority, prerequisite, external state, or user decision missing

## Verification

- exact checks by task class
- candidate identity requirements
- independent-review triggers
- subjective evidence requirements

## Project-specific anti-patterns

- signal:
- evidence required:
- open question:
- allowed response:

## Documentation discipline

- record only non-obvious decisions — never what the code already
  shows (example of a worthy entry: "sessions live in Redis, not
  MySQL, because X" — so a later reviewer doesn't suggest migrating
  them back)
- keep only active plans; delete completed plans after commit+push
  (leftover plans pollute later agents' searches)
- tiny tasks skip the plan step entirely
- the protocol may pin the exact tool + params the Lead uses to create
  agents here, so the Lead doesn't re-derive it per task

## Protocol evolution

- Supervisor records causal evidence in its notebook
- Human approves material authority changes
- preserve version history
- review after a repeated pattern or major architecture change
