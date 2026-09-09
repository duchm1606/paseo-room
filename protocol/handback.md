# Handback (peer/Engineer → Lead)

A handback returns a lease upward with evidence. Moving state and
authority sideways to a successor is a *handoff* — see `handoff.md`.

1. Conclusion / deliverable
   - scope actually handled, checked against the granted lease
2. Evidence — exact snapshot + personally observed verification
   (with environment context: fresh run vs cache, locks held)
3. Confidence level — facts separated from inference
4. Unproven assumptions
5. Risks / strongest counterargument
6. **Standing dissent** (if any) + reversal conditions
7. Incidental discoveries — out-of-scope findings go here, never
   "fixed while I was there"; the Lead decides reopen / file / ignore
8. Suggested next step (a suggestion, not a decision — the Lead rules)
9. **Reaction disposition**: `CONFIRM`, `PARTIAL`, `CHALLENGE`, or
   `BLOCKED` — a position is mandatory; opposition is not.
10. Terminal sentinel — one final line marking the lease as returned,
    so a `done`/`idle` status without it is a finish routing strand,
    not a handback.

Lead handling: check evidence before accepting any conclusion (never accept
merely because the agent is strong), look for contradictions across
handbacks, question the foundation. Overriding a dissent → state the ruling
and its reasons in the conversation before proceeding (session logs are the
archive; no record files).
