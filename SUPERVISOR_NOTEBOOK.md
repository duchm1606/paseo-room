# Supervisor Notebook

> Sổ ghi chép học tập xuyên workspace của Supervisor (causal context, không phải
> phán xét). Chỉ ghi thêm khi có pattern mới hoặc bằng chứng mạnh hơn; gom hành vi
> lặp lại theo pattern. Mỗi entry: Observation / Evidence / Suspected mechanism /
> Impact / Question for Lead / Recommendation / Escalation needed?

## Format entry

```md
## <Tên pattern>

- Observation:
- Cause evidence:
- Suspected mechanism:      # hypothesis until evidence supports it
- Impact:
- Anti-pattern:
- Pattern status:           # first occurrence | repeat of <pattern> | unconfirmed
- Open question for Lead:
- Recovery / intervention:  # and the exact lease it was taken under
- Outcome:
- Protocol candidate:
- Human decision needed:
```

Aggregate a repeat under its existing pattern entry rather than opening a new
one; the notebook records durable learning, not a transcript.

## Log

## Supervisor seat becomes the command channel (convener + contract author + plan acceptor)

- Observation: On `wks_3cc39ad0f066f9c2` (pptx layout-fill+refine sealed council,
  2026-09-03) the Human's entry point was a `supervisor` seat (`04d8c01`). That
  seat authored the bd council contract `trusty-bot-3lg` (COUNCIL QUESTION +
  evidence bundle + seat mandates + verdict procedure), spawned the Lead
  (`e1280439`) via `create_agent`, and accepted the Lead's plan with
  "Plan APPROVED — proceed".
- Cause evidence: `04d8c01` activity — `bd create "[council] ..." -d "COUNCIL
  QUESTION ..."`; `create_agent {title:"Lead: pptx layout-fill+refine ..."}`;
  `send_agent_prompt {"Plan APPROVED — proceed ..."}`. Lead `e1280439` carries
  label `paseo.parent-agent-id: 04d8c016`.
- Suspected mechanism: the machine's default Human entry point is a
  supervisor-provider seat; with no separate Human-proxy and no direct
  open-a-Lead path, a supervisor slides into convener + command channel. The seat
  read the Human's "read the protocol instead of guessing" as an implicit setup
  lease and framed the contract itself.
- Impact: question-channel and command-channel collapse into one
  (Human→Supervisor→Lead); the council QUESTION was framed by the Supervisor,
  whereas both the doctrine (Ch 6/7) and this repo's `WORKSPACE_PROTOCOL.md`
  sealed-council lane assign framing to the Human. Doctrine Ch 6 names the risk:
  "the governance plane becomes a second Lead, and instantly there are two command
  chains."
- Anti-pattern: Supervisor overreach — acting on initiative rather than an
  explicit Human lease, and accepting work (a decision act the Supervisor may not
  perform).
- Pattern status: first occurrence on this machine's setup; structurally
  recurrent while the entry point is a supervisor seat.
- Open question for Lead: n/a — this is a Human/setup decision, not a Lead ruling.
- Recovery / intervention: none taken live — the council was already complete and
  correctly Human-gated (skill doctrine). Audit ran under a read-only supervisor
  lease (observe + compare against doctrine + report); no code or lifecycle change.
- Outcome: council EXECUTION was doctrine-faithful (sealed, heterogeneous
  Fable/Opus seats, blind lanes, Lead kept the crux out of shared scratch,
  reconcile with verification + one challenge round, no vote, escalated the one
  unmeasured economic call, kept skill Human-gated). Divergence isolated to (1)
  the supervisor seat's command role and (2) a dropped finish-event — the Lead
  finished idle with `requiresAttention:false`, never pinged, and the Human had to
  poll ("sao không thấy báo lại"); matches Ch 17 "bells that didn't ring" and the
  dropped-handback pattern.
- Protocol candidate: (1) for expensive-to-reverse councils, the Human — not the
  Supervisor — authors/approves the bd COUNCIL QUESTION (protocol already says so;
  enforce in practice). (2) when a Supervisor is to spawn a Lead, require an
  explicit one-line Human lease ("go create the Lead, pass on what we discussed").
  (3) wire a Lead finish/handback event so completion does not depend on polling.
- Human decision needed: choose (A) keep the supervisor-as-entry-point convention
  and patch framing-ownership + finish-event, or (B) open Leads directly and keep
  the Supervisor as watcher / question-channel only.

## Maintenance — trustybot-backend WORKSPACE_PROTOCOL aligned to template

- Observation: `trustybot-backend/WORKSPACE_PROTOCOL.md` bumped v4 → v5 (2026-09-03)
  to follow `protocol/workspace-protocol.template.md`, on explicit Human instruction.
- Cause evidence: v4 was missing five template sections — Issue tracker (full,
  fail-closed + Codex read-only limit), Brief discipline (no option-menu / no
  pre-solve), Context budget (~45% compact), Ultra-review gate, Documentation
  discipline.
- Impact: added the five sections; upgraded the thin "Intake" into the full Issue
  tracker section. Authority semantics were NOT changed — repo-specific lanes
  (schema/migration, prompt/skill Human-gate, hotfix), the sealed-council lane,
  routing map, drift anti-patterns, and endgame/reporting were preserved verbatim
  in substance.
- Anti-pattern: n/a (maintenance).
- Pattern status: first occurrence.
- Recovery / intervention: taken under an explicit Human lease to align the file to
  the template; no authority change, so no separate Human authority-approval needed.
- Protocol candidate: Brief discipline (added) is the durable guard against the
  divergence logged above — writable-owner briefs must forbid option-menu stops;
  council/review briefs must never hint the Lead's preferred answer or pre-solve.
- Human decision needed: none for the alignment itself; the (A)/(B) setup choice
  above still stands.
