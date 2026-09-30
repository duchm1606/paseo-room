---
name: triple-review
description: "Run the Lead-owned three-lane review of one stable material implementation: two sealed semantic lanes from different provider families plus one exhaustive-coverage lane. Routes, models and effort come from the applicable WORKSPACE_PROTOCOL.md, never from this skill. Use only when that protocol requires this review shape or the Human explicitly requests it; do not use for an unstable candidate, an ordinary bounded review, or from Peer/Supervisor authority."
---

# Triple Review

Use Paseo to obtain independent semantic judgment and an accountable per-file coverage sweep without creating a vote. Lead alone invokes this skill, receives every handback, confronts material contradictions, and issues the technical verdict.

This skill names no provider, model, or effort. The applicable `WORKSPACE_PROTOCOL.md` pins all three for every lane.

## Preconditions

Before creating a seat:

1. Bind the exact workspace, current Lead lease, applicable `WORKSPACE_PROTOCOL.md`, and candidate contract.
2. Freeze one stable candidate identity that every lane can reproduce, such as an immutable commit or an exact base/head pair. Do not review moving worktree bytes.
3. Write one neutral review brief containing the candidate identity, intended behavior, relevant product constraints, and requested evidence. Do not include suspected defects, another lane's findings, or a preferred conclusion.
4. Read the three lane routes — provider, model, and effort for semantic lane A, semantic lane B, and the coverage lane — from the workspace protocol, and confirm each model is currently offered on the daemon. If the protocol pins no triple-review routes, stop and ask the Human; do not invent a roster, and never silently substitute an unavailable route.

If the target is unstable, a required route is unavailable, or Lead cannot state the review boundary, stop with the concrete blocker. Do not degrade to fewer lanes and still call the result triple review.

## Launch three sealed lanes

Create all three as Paseo children of Lead, each pinned to the exact provider, model, and effort the protocol names, and let them inspect independently:

- Semantic lane A and semantic lane B: the two semantic routes. They must come from **different provider families**; independence comes from separate provider and session lineage, not from a model name. If the protocol's two semantic routes share a family, report that as a protocol defect before launching.
- Coverage lane: the coverage route. It is an ordinary role-bound Peer. What makes it the coverage lane is the coverage contract in its assignment, not a special provider, execution profile, or tool.

The two semantic assignments receive only the neutral brief and ordinary Peer constraints. Do not reveal the coverage lane, its contract, or its findings to either semantic seat.

Every lane is behaviorally read-only for the whole assignment: it reads frozen git objects (`git show <sha>:<path>`), states the identity it read against, and never edits, fixes, commits, pushes, posts, or coordinates other seats.

Never seed a lane with another lane's findings or conclusions during the sealed pass. Do not ask one seat to supervise, coordinate, or reconfirm another.

## The coverage contract

The coverage assignment carries the neutral brief plus this contract:

- Establish the candidate identity before inspection and verify it again before handoff. If it changed, stop and report `STALE_CANDIDATE` with the old and observed identities; never combine evidence across snapshots.
- Build the exact file manifest of the candidate from its identity (for a base/head pair, `git diff --name-status <base> <head>`). Give every entry exactly one disposition: **reviewed** (substantively inspected in repository context), **excluded-with-reason** (outside the contract, with a concrete reason), or **metadata-only** (accounted through identity, type, or change metadata; deleted and non-text files may use this). Report the manifest total and each disposition total; they must sum exactly to the manifest total. Do not silently omit generated, vendored, binary, renamed, deleted, or test files. If complete accounting is impossible, stop and report the concrete gap to Lead.
- Shape every finding as a hypothesis: evidence (exact location and a reproducible observation), consequence (the concrete behavior or risk if true), disproof (the smallest check that could falsify it), and the smallest correction, described and not implemented. Try to falsify your own findings. There is no finding quota; a clean sweep is reported as clean.
- Passing tests and lifecycle status are evidence, not acceptance.

Lead does not direct the lane's internal order of work, but may always ask how a disposition was reached: an accounting Lead cannot reproduce is not evidence.

## Require accountable handbacks

Each semantic handback must identify the candidate and contract, record checks run, provide evidence-backed findings and uncertainty, and state whether the candidate remained stable.

The coverage handback must additionally carry the manifest with every entry's disposition and the totals, the exact commands and checks run, and findings ordered by severity. Coverage is evidence of what was examined, never a review conclusion.

Reject a handback as stale if its observed candidate differs from the frozen identity. Do not combine evidence across snapshots or infer acceptance from test status, silence, or coverage alone.

## Converge and adjudicate

Lead compares mechanisms and evidence, not reviewer count. There is no majority vote, and the coverage lane is not a third semantic ballot.

When a lane runs on the same model that authored the candidate, it is a second pass rather than an independent one: weigh its findings like any lane's, but accept its clean result only on evidence it produced, never on its assurance.

When the semantic lanes conflict materially—for example, one requires a synchronous boundary and the other an asynchronous one—Lead writes the contradiction as two falsifiable claims, identifies the governing product or architecture constraint, and returns a neutral contradiction packet to exactly the conflicting lanes after both sealed handbacks exist. Ask each lane:

- what evidence would disprove its own position;
- whether the opposing mechanism can satisfy the same constraint;
- what smallest bounded check resolves the disagreement;
- whether it yields, narrows, or maintains its claim after that check.

Lead may run or route the smallest bounded reproduction needed to resolve the mechanism. Lead then records the accepted claim, rejected claim, decisive evidence, residual uncertainty, and correction route. Repeated findings that share one lifecycle, ownership, state, contract, or foundation mechanism trigger a reopen decision rather than a chain of symptom patches.

Use a council only when this confrontation leaves a consequential decision unresolved or the Human explicitly requests one. The council owns its own mechanics; it is not a routine fourth lane.

## Handoff

Return one compact Lead artifact containing:

- stable candidate identity and reviewed contract;
- exact routes and lane receipts, and the protocol version they were read from;
- sealed-pass status and any stale or dependency signal;
- semantic findings and the coverage accounting artifact;
- contradiction packets, falsification checks, and lane responses;
- Lead's verdict, correction ownership, residual risk, and any Human decision required.

Only Lead may issue `ACCEPT`, `REVISE`, or reopen the route. Review seats never mutate the candidate, implement fixes, coordinate other seats, or claim room acceptance.
