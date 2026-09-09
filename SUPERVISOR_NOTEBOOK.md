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

## Incident — Lead and Peer seats hard-down on blank per-profile OAuth credentials

- Observation: 2026-09-09 ~14:47–14:56 local, workspace `wks_d703e439aeaf54b1`.
  Lead `bf26fd85` failed its evaluation assignment and two auth probes with
  `Failed to authenticate: OAuth session expired and could not be refreshed`
  (3 distinct timeline entries). A freshly created Lead `d00fd8f9` failed
  identically, ruling out a stuck process.
- Cause evidence (verified): role profiles do NOT read
  `~/.claude/profiles/claude-<role>/.credentials.json`. The Claude CLI stores each
  profile's credential in its own macOS keychain entry named
  `Claude Code-credentials-<sha256(CLAUDE_CONFIG_DIR)[:8]>`. Mapping confirmed by
  hashing the profile paths:
    - claude-supervisor -> `-01c7ddd8` : VALID
    - claude-lead       -> `-17f37220` : BLANK (accessToken/refreshToken "", expiresAt 0)
    - claude-peer       -> `-390482df` : BLANK
  Shared operator entry `Claude Code-credentials` was VALID throughout; seeding it
  into a throwaway temp profile gave `claude -p` -> `OK`, exit 0. Failure also
  reproduced outside Paseo via
  `CLAUDE_CONFIG_DIR=~/.claude/profiles/claude-lead claude -p` — not a Paseo defect.
- Suspected mechanism (hypothesis, unverified): all three profiles were seeded from
  one credential and therefore shared a single refresh-token lineage. Anthropic
  rotates refresh tokens on use; the first seat to refresh invalidates the others,
  and the losing profiles persist an empty record. Consistent with timing —
  supervisor refreshed ~14:49, lead blanked at 14:47.
- Impact: Lead and Peer seats were unstaffable account-wide. Only Supervisor could
  run, so no workspace could be worked at all. Silent: nothing surfaces the blank
  credential until a seat is prompted and errors.
- Stale doc found: the comment block in `~/.paseo/orchestration/bin/claude-profile`
  instructs "delete the profile's .credentials.json and relaunch to re-seed" as the
  recovery for a "Not logged in" seat. That recovery no longer works — the file is
  not the credential source. NOT corrected; flagged for the owner.
- Pattern status: first occurrence.
- Recovery / intervention: taken under an explicit owner lease ("test thử với lead
  claude", then owner chose "Copy shared cred now" from a presented option set).
  Wrote the valid shared credential into the two blank keychain entries via
  `security add-generic-password -U`. Verified: direct CLI probes on both the lead
  and peer profiles returned `OK`; Paseo Lead seat `9513e6fe` returned `OK` and was
  archived along with probe seat `d00fd8f9`. Also repaired
  `claude-lead/.credentials.json` (backup `.credentials.json.bak.1788940385`) before
  the true cause was known — that edit had no effect and can be reverted.
- Known residue: Lead `bf26fd85` still holds the Cowork base-evaluation assignment
  but its process was spawned against the dead credential; it now reports
  `Not logged in · Please run /login` and needs replacement, not resumption.
- Protocol candidate: the fix restores the shared refresh-token lineage, so the race
  can recur. Durable fix is a separate `/login` per profile so each seat owns an
  independent OAuth session. Worth a startup-time credential preflight so a blank
  profile is caught before a Lead is briefed rather than after.
- Human decision needed: whether to do the per-profile `/login`, and whether to
  correct the stale recovery comment in `bin/claude-profile`.

### Addendum — root cause confirmed by token fingerprinting (2026-09-09 15:00)

The rotation hypothesis logged above is now verified, and one detail in it was wrong.

- Measured SHA256[:10] of access/refresh tokens across the four keychain entries:
    shared     accessFP=8899bded5b refreshFP=dabf62aa3e
    lead       accessFP=8899bded5b refreshFP=dabf62aa3e
    peer       accessFP=8899bded5b refreshFP=dabf62aa3e
    supervisor accessFP=176d19f4c5 refreshFP=5fe1fa67ff
  lead/peer/shared are byte-identical copies of ONE credential; supervisor sits on an
  independent lineage (distinct `refreshTokenExpiresAt`: ...528047 vs ...528587).
- Rotation observed directly: after the peer probe seat ran, that profile's
  `refreshTokenExpiresAt` moved 1789068528587 -> 1791481806892, i.e. the refresh
  token was replaced, not reused.
- The discriminating variable is therefore lineage sharing, and supervisor — the one
  profile NOT sharing — is the one profile that never failed.
- Correction to the entry above: it claimed all three role profiles shared one
  lineage. Only lead and peer do. Supervisor needs no re-login.
- Root cause (settled): the seeding step in `~/.paseo/orchestration/bin/claude-profile`
  copies a single keychain credential into each role profile, while the provider
  rotates refresh tokens on use — so the first profile to refresh invalidates the
  others' copies. Not a Paseo defect and not model-related.
- Still unverified: the blanking write itself. Presumed to be Claude Code clearing a
  stored session after a refresh returns invalid_grant; the write was never observed.
- Live risk: the applied fix restored the shared lineage. Shared access token expires
  22:49:39 today; the race re-arms at that point.
- Durable fix: a separate `/login` per profile for claude-lead and claude-peer, so
  each seat owns an independent OAuth session. Not yet done — owner's call.

## Owner overrides a Supervisor legal fence on unlicensed vendored source (2026-09-09)

- Workspace `wks_8c48b3503d5c3505`, `trusty-bot/trustybot-cowork-old`. Owner directive:
  build an office-file (docx/xlsx/pptx) cowork product on the LiteLLM endpoint in
  `.env`, with its own harness; stated lean toward forking `t3code`; explicit question
  about copyright exposure. This resolved the `intended product scope: UNSET` field
  that `WORKSPACE_PROTOCOL.md` v1 reserved to the Human.
- Evidence gathered before staffing (commands: `head -6 <repo>/LICENSE*`,
  `git -C <repo> remote -v`, `git -C <repo> log -1`, run 2026-09-09 across
  `.references/`): t3code MIT © T3 Tools Inc. (pingdotgg/t3code); synara MIT (fork of
  same lineage); deer-flow MIT © Bytedance; AionUi Apache-2.0; suna **Elastic License
  2.0**, not OSS; `claude-code-main` **no LICENSE, no `.git`, no remote, no
  `package.json`**, layout (`QueryEngine.ts`, `query/`, `ink/`, `entrypoints/`,
  `memdir/`) consistent with extracted Claude Code internals.
- Supervisor action: staffed ONE seat (Lead `efaf2f62`, `lead/claude-opus-5`, xhigh,
  bypassPermissions) and left peer creation to Lead — the owner named the pair
  (`peer/claude-opus-5`, `codex-peer/gpt-5.6-sol`) but staffing them directly would
  have built a parallel command chain. Provisionally fenced `claude-code-main` in the
  brief (concepts citable, no code lift, not eligible as fork base) and raised the
  ruling to the owner as a Human decision, rather than deciding it.
- Owner ruled: remove the fence, treat it as an ordinary reference. Ruling was made
  with the exposure stated in the option text. Relayed to Lead verbatim in substance,
  with §5 read-only/`.env`/Harness-v0 constraints explicitly preserved and the Q2
  provenance finding kept as a factual record item, not a warning.
- Pattern (first occurrence here, recurring shape): when a Supervisor-set fence is a
  *provisional safety default* rather than protocol law, name it as provisional in the
  brief at the moment it is set. That made the override a one-message amendment with a
  clean supersedes-§4 boundary instead of a renegotiation with the Lead.
- Anti-pattern avoided: the owner's stated `t3code` lean was passed to Lead but
  withheld from the sealed peer briefs. Leaking a Human lean into sealed dual-design
  lanes collapses them into confirmation of a preselected answer.
- Open: `git init` remains the one unanswered Human-only field in
  `WORKSPACE_PROTOCOL.md`; it becomes blocking the moment a fork is actually taken,
  since candidate identity currently degrades to per-file `shasum`.

### Addendum — Lead-declared assumption inverted by the owner (2026-09-09, same workspace)

- Lead `efaf2f62` issued a binding verdict (base: `deer-flow`) and filed alongside it the
  exact assumption the verdict rested on: *"Hosted vs never-hosted delivery — this flips
  the answer... I assumed eventual hosting."* Owner then answered **desktop/on-prem,
  never hosted** — the inverse.
- Because the assumption was named as a decision with its flip condition stated, the
  correction cost one relay message and a bounded re-open of Q1. Had the verdict merely
  *contained* the hosting premise implicitly, the owner would have accepted a
  recommendation whose discriminator (ELv2 hosted-service ban) does not apply.
- Pattern worth propagating to Lead profile / workspace protocol: **a verdict that turns
  on an unresolved Human premise must name the premise, the flip condition, and the
  direction it was assumed** — not just file "Human decides X". The flip condition is what
  makes the later correction cheap.
- Supervisor guarded two over-reads when relaying: (a) "ELv2 no longer blocks" ≠ "suna
  wins" — the re-open was ordered on merits, not as a flip; (b) "no hosting" removes AGPL
  §13 network trigger but NOT distribution-attaching copyleft duties for a shipped desktop
  binary. Both stated as cautions against inference, not as conclusions — the analysis
  stays Lead's.
- Also relayed: `git init` approved, fenced with `.gitignore` for `.env` (live
  `LITELLM_API_KEY`) and `.references/` required BEFORE first `git add`, verified via
  `git status --porcelain`. A bare `git add .` there would have committed a live
  credential plus six vendored upstreams in one move.

### Addendum — Supervisor hypothesis falsified by seat measurement (2026-09-09, same workspace)

- Supervisor sent an attention packet: Lead had substituted `claude-fable-5-1` for the
  protocol's unsatisfiable Architect pin `claude-fable-5-1[1m]`, and the packet
  hypothesised it had traded away the 1M window the pin existed for.
- **Hypothesis falsified by direct measurement.** Lead reported from the live seat:
  `contextWindowMaxTokens: 1000000`, used 13.7%. `claude-fable-5-1` is 1M-native; the
  `[1m]` suffix marks models whose long-window form is a separate SKU (cf. `claude-opus-5`
  labelled "Opus 5 (1M)" with no suffix). `list_models` labels do not carry window size
  reliably — **do not infer context window from a model label; measure the seat.**
- Lead's separation is the reusable output, worth more than the config fix: *"reasoned
  badly and landed correctly — worth separating, because only one of those needs fixing."*
  Lead also answered the mechanism question with "as a side effect" rather than
  retrofitting a rationale, which is what made the reasoning defect visible at all.
- Supervisor lesson: keep the packet's *mechanism* claim and its *impact* claim separable,
  and label impact as hypothesis. Here the mechanism claim was correct and the impact
  claim was wrong; a packet that fused them would have been dismissed whole, and the
  reasoning defect — and the protocol fix it produced — would have been lost with it. A
  packet that turns out to be a false alarm on impact is still worth sending.
- Outcome: protocol v4 (`1c5b915`) removed the unsatisfiable pin from all three routing
  entries and recorded **which property is load-bearing (context window, not model tier)**
  plus a defined fallback direction and the verified 1M set. Lead judged this routing
  hygiene inside its own authority and did not escalate; Supervisor confirmed that reading.
- Pattern for Lead profile / protocol template: a routing pin should record the *property*
  it protects, not only the model ID. An ID-only pin has no defined fallback when the ID
  goes unavailable, and the next seat resolves it by name-matching — losing the property.

### Addendum — unconsumed `finished` attention flag reads as a stall (2nd occurrence, 2026-09-09)

- Occurrence 1: Lead consumed Seat C's handback via `get_agent_activity` but never cleared the
  seat's `requiresAttention: "finished"` flag. Supervisor read the flag as an unread handback
  and nudged; the verdict had in fact already been issued.
- Occurrence 2: Lead finished PKG-01 at 09:55 with its own `requiresAttention: "finished"`
  flag toward Supervisor still set and the content not delivered into the Supervisor session.
  The project owner noticed before the notification did — asked "sao thằng lead xong rồi mà
  không báo". Content was intact and retrievable via `get_agent_activity`.
- Pattern (now confirmed, not incidental): **a set `finished` flag is not evidence that work
  is unread, and an absent notification is not evidence that work is unfinished.** Both
  directions of that inference have now failed once each in this workspace.
- Supervisor practice that worked both times: check `list_agents` for live status and
  `get_agent_activity` for content rather than waiting on push delivery, and when reporting a
  suspected stall, state the timestamps and let the Lead correct the conclusion. In occurrence 1
  that framing is what let Lead separate "your read of the evidence was correct, only the
  conclusion was off" instead of a dispute.
- Owner-facing consequence worth saying out loud: push notification is not a reliable liveness
  signal here; periodic explicit status checks are the dependable path.

## Pre-registered decision rule defeats consistency pressure in a Lead (2026-09-09)

- Setup: Lead `efaf2f62` had authored a composition verdict (deer-flow base) and defended it
  through two owner constraint changes. Across two consecutive reports it stated the rival
  TypeScript branch "got stronger" while concluding the verdict holds — the classic shape of
  a position being protected rather than tested.
- Supervisor packet named the risk **as a hypothesis about the Lead's position, not an
  accusation**: four rounds invested, authored the verdict, defended it twice — "exactly the
  setup where consistency pressure quietly does the reasoning." Asked it to decide in advance
  what result would make the rival win, and stated that a third "stronger but verdict holds"
  was not an acceptable outcome.
- Lead's response is the reusable artifact: it filed a **pre-registration** (`trusty-bot-4q1h`)
  in the tracker, **timestamped ahead of any findings**, containing a Gate-0 question, explicit
  win conditions for each branch, and a **named kill condition for each** — including for its
  own recommendation.
- It then **corrected its own prior claim before the evidence arrived**: "inherit Paseo's whole
  story for free" was overstated, because CPython is 67 MB against LibreOffice's ~600 MB, so if
  `soffice` ships either way the packaging cost is dominated by the payload both branches carry.
  It stated plainly that the evidence already in hand cuts against the branch the owner had just
  asked it to champion.
- Pattern to propagate (Lead profile / workspace protocol): when a Lead must re-evaluate its own
  standing recommendation, require a **pre-registered decision rule with kill conditions on both
  sides, recorded in the tracker before investigation opens**. It converts an unfalsifiable
  re-confirmation into a testable claim, and it gives the Lead a legitimate way to change its
  mind without it reading as capitulation.
- Supervisor technique that made it land: name the bias as a structural property of the position
  (rounds invested, authorship, prior defences) rather than as a quality judgement about the
  agent. The Lead engaged with it directly — "you named the risk correctly" — instead of
  defending.

### Outcome — cowork base selection closed (2026-09-09)

- Owner accepted Package A: TypeScript runtime + broker containment over OS primitives +
  copied genoffice OOXML engines (Apache-2.0). `trusty-bot-34t` closed after five rounds.
- The answer inverted the owner's opening lean twice over: they asked whether forking
  `t3code` had a copyright problem. It did not — MIT is clean — but `t3code` lost on fitness
  (no office capability, no agent loop, developer-audience UI), and the eventual answer was
  neither `t3code` nor the round-1 winner `deer-flow`.
- **What actually moved the decision was owner questions, not agent analysis.** Two of them
  broke load-bearing assumptions no agent had tested in four rounds: "what is soffice even
  for?" (it was never on the core path — LibreOffice was a capability tier, not a baseline
  dependency) and pointing at two office repos (`genoffice` held pure-TypeScript OOXML
  engines — the Tier 1 existence proof the whole branch decision turned on).
- Supervisor lesson to carry: when an owner asks a naive-sounding question about a term the
  room has been using confidently for hours, route it as a real investigation rather than
  answering it from the room's own accumulated framing. The framing is exactly what has not
  been tested. Both times the cheap answer would have been wrong.
- Lead reversed its own verdict twice on evidence and documented its own errors for a
  successor. The pre-registration mechanism (kill conditions filed before investigating)
  held through three amendments and is the single most transferable artifact here.

## LEAD REPLACEMENT RECEIPT — trustybot-cowork-old (2026-09-09)

- **Human recovery mandate:** project owner, verbatim — *"Bàn giao đi cơ mà đừng có implement nhé."*
  Not a recovery: the outgoing Lead was healthy and recommended its own handoff at 48.7%
  context (486,747/1,000,000), above the protocol's 45% threshold, on the grounds that the
  build phase is better served by clean context than accumulated investigation context.
- **Old Lead binding revoked at:** 2026-09-09 ~12:50 UTC. `efaf2f62-9b8a-4536-ac88-77b884a64491`
  archived. Revocation verified by `list_agents` returning without it BEFORE the successor was
  created — break-before-make held, no interval with two bindings on the scope.
- **Old Lead checkpoint:** packet `trusty-bot-dewc` updated to final state before revoke.
  Marker blocks present and confirmed: NEXT PERMITTED ACTION, STOP CONDITIONS, SUCCESSOR'S
  FIRST ASSIGNMENT, LEAD ERRORS TO NOT REPEAT. Delegation frozen at Supervisor instruction
  one turn before revoke.
- **Unresolved work / agents:** zero seats parented to the outgoing Lead remained (verified by
  `list_agents`, no `paseo.parent-agent-id: efaf2f62` entries). Outgoing Lead independently
  caught one stale archive — `2ce2c879` reported `archivedAt: null` after an archive call
  returned success — and re-archived rather than reporting it clean. **Paseo archive calls can
  return success without taking effect; verify, do not trust the return value.**
- **New Lead binding activated at:** 2026-09-09 ~12:51 UTC, `e8d9ae20-f79b-4b06-ae61-f251da42d937`,
  `lead/claude-opus-5`, xhigh, bypassPermissions, fresh context. Packet delivered as the first
  prompt with an explicit instruction not to read the old transcript.
- **Reconciliation result (Supervisor-verified, independent of both Leads):** HEAD `e4a1409`,
  7 commits, tree clean, 11 tracked files, `.env` untracked and ignored, 0 `.references/` paths
  tracked, 0 occurrences of a `LITELLM_API_KEY` **value** anywhere in history,
  `docs/decisions/0001-architecture-typescript-runtime-broker-containment.md` present,
  `WORKSPACE_PROTOCOL.md` at v5.
- **Writes re-enabled at:** **NOT re-enabled.** The owner approved the first slice and then
  withheld the start. Successor's next permitted action is acknowledge-and-wait; product-code
  writes remain unauthorised. Its first assignment is investigation only (LangGraph versus own
  harness). This is the unusual case the receipt template does not anticipate — **authority
  transferred without the write authorisation the transfer would normally carry** — so it is
  stated explicitly rather than left blank.

## Detecting writes by a non-read-only seat in a git-ignored tree (2026-09-09)

- Problem, generalisable: a `codex-peer` seat has **no enforced read-only mode** (its modes are
  auto / auto-review / full-access), and the tree it must inspect (`.references/`) is
  **git-ignored** — so `git status` cannot detect writes to it. The usual "the diff will show it"
  control is blind exactly where the risk is.
- Supervisor had noticed the mode asymmetry earlier (Seat A in `plan`, Seat B write-capable) and
  judged it not worth an advisory because `auto` was the most restrictive mode available and the
  brief carried the read-only constraint. **That reasoning was incomplete**: it addressed
  intent but left no detection. The successor Lead closed it properly.
- Control it used, worth reusing: capture a **pre-launch manifest of the whole tree**
  (path + size + mtime for all 41,240 files), hash it (`sha256 a8ebeac0…`), and re-check on
  handback. Cheap, needs no cooperation from the seat, and turns "we told it not to" into
  "we can prove whether it did."
- Rule for future briefs: when a write-capable seat is pointed at a tree git cannot observe,
  a stated constraint is not a control. Pair every read-only instruction over an ignored or
  untracked path with a manifest-and-recheck, or accept that the constraint is unverifiable.

## Absence claims need a positive control — Supervisor included (2026-09-09)

- Two independent "file does not exist" findings were both wrong, from one defect:
  **`/tmp` is a symlink to `/private/tmp`, and `find(1) does not follow a symlinked search root`.**
  `find /tmp -iname 'paseo-src'` returns nothing for a directory that `ls /tmp/paseo-src` lists
  fine. On macOS this silently invalidates every `find /tmp ...` result.
- Lead reported Paseo and genoffice as absent on that basis, escalated a P0 blocker
  (`trusty-bot-def5`) to the owner, and narrowed a running lane's scope to "a third of intended".
  All three were artifacts of the defect.
- **Supervisor repeated the same class of error while "independently verifying" it.** I ran
  `ls -1 /private/tmp | head -40` — alphabetically truncated before `repo-probe/` — and reported
  to the project owner that genoffice was genuinely absent, that the office-layer evidence was
  unreproducible, and recommended they acquire the repo. A truncated check was presented as an
  exhaustive one. The owner received a false fact with an action attached.
- What actually caught it: the Lead ran a **positive control** — searching for a directory it had
  already listed successfully — and the control failed. Nothing else in the chain would have.
- Standing rules, now in the workspace's `a5ik` and worth carrying everywhere:
  1. **An absence claim must state its search roots** so a reader can see what was not covered.
  2. **An absence claim must carry a positive control** — search for something known to be there
     by the same method; if the control fails, the method is broken, not the target.
  3. `head`/`maxdepth`/symlinked roots all silently convert "did not look" into "is not there".
- Supervision lesson, sharper than the technical one: I had been correctly policing exactly this
  failure in seats ("asserted an absence it had not established") for several rounds, then
  committed it myself and shipped it to the owner as verified fact. **Verifying a subordinate's
  claim with a weaker method than theirs is worse than not verifying it** — it launders a guess
  into a confirmation. State the command actually run, not the conclusion drawn.

### Addendum — truncation errors reached four in one chain (2026-09-09)

Same workspace, same day, four independent silent-truncation failures, none of them carelessness:

1. Lead: `find /tmp ...` — `find(1)` does not follow a symlinked search root (`/tmp` → `/private/tmp`).
2. **Supervisor**: `ls -1 /private/tmp | head -40` — alphabetically truncated before the target;
   reported to the project owner as exhaustive, with a recommendation attached.
3. Lead: `head -3 synara/LICENSE` — cut exactly one line short and lost the second copyright
   holder, which is a live MIT notice-retention obligation on any copied code.
4. Lead: a zsh glob silently zeroed a grep during the verification of (3).

All four were caught only by a **positive control** — searching for something known present by the
same method and checking the method returns it. None would have been caught by more care.

The generalisation is stronger than the earlier entry stated: **`head`, `maxdepth`, symlinked
roots and shell globs all convert "did not look" into "is not there", silently, and they do it to
careful operators.** Treat every negative result as suspect until a control has passed on the same
command shape. This now applies to licence text as much as to file existence — (3) would have
shipped a defective attribution into a product.

### Addendum — OAuth lineage race recurred exactly as predicted (2026-09-09 22:49 +07, 2nd occurrence)

- The morning entry closed with: *"the applied fix restored the shared lineage. Shared access
  token expires 22:49:39 today; the race re-arms at that point."* **It re-armed at 22:49:39.**
  A `peer/claude-opus-5` Engineer seat died at startup with the identical error and blocked the
  first build kickoff of the project.
- Measured at 22:53: `shared` EXPIRED 231s prior; `supervisor` and `lead` both refreshed
  successfully with **new** fingerprints; `peer` **BLANK/BLANK/expiresAt 0**. Lead won the
  refresh race, peer's copy was invalidated and persisted empty. Mechanism fully confirmed —
  no longer a hypothesis.
- **New, generalisable:** `list_providers` reporting a provider as `available` is a **static
  registry view, not a live credential check**. It disagreed with runtime reality. Provider
  status is not an auth signal; a one-line liveness probe is, and costs nothing. The Lead
  established this by contradiction before retrying, which is why the diagnosis took minutes.
- **Missing control, now twice-demonstrated:** nothing surfaces a blank credential until a seat
  is prompted and errors. A startup-time credential preflight would have caught this before a
  Lead was briefed. Proposed in the morning entry, still not built.
- Owner directed the same repair as before ("copy lead's credential to peer now") with the
  re-arm trade stated explicitly. Executed and verified: peer entry
  `Claude Code-credentials-390482df` now carries accessFP `fa51379bb7`, matching lead.
  **Next re-arm: 2026-09-10 06:48:09 +07.** Recorded so the third occurrence is predicted
  rather than re-diagnosed.
- Pattern status: **second occurrence, prediction confirmed to the minute.** The copy repair is
  a ~8-hour patch by construction, not a fix. The durable fix — a separate `/login` per profile
  so each seat owns an independent OAuth session — has now been deferred twice and has cost one
  build kickoff. Worth raising as a standing item rather than per-incident.

## `bd init` ships an AGENTS.md that mandates `git push` — repo bootstrap must override it

- Observation: bootstrapping `pptx2html-llm` (2026-09-09, `wks_c9971fc0bd824652`),
  `bd init` generated a repository-root `AGENTS.md` containing a block headed
  **"Session Completion / MANDATORY WORKFLOW"** with the literal rules *"Work is
  NOT complete until `git push` succeeds"*, *"NEVER stop before pushing"*, and
  *"NEVER say 'ready to push when you are' - YOU must push"*, plus `bd dolt push`.
- Cause evidence: `/Users/duchoang/Projects/pptx2html-llm/AGENTS.md`, inside the
  `<!-- BEGIN BEADS INTEGRATION v:1 profile:minimal hash:ca08a54f -->` block
  written by `bd version 0.62.0 (dev)` during `bd init --prefix p2h`.
- Suspected mechanism: beads targets solo repos with a remote and treats push as
  the durability boundary. Room law treats push as an external effect requiring
  explicit authority, and a fresh room repo has no remote at all.
- Impact: a seat that reads `AGENTS.md` and obeys it will attempt an unauthorised
  external effect, or loop retrying a push that cannot succeed ("if push fails,
  resolve and retry until it succeeds"). It arrives on **every** new beads repo,
  so this is a standing bootstrap defect, not a one-off.
- Anti-pattern: generated tool boilerplate silently outranking room law because it
  is louder (ALL CAPS "MANDATORY") and closer to hand than the protocol.
- Pattern status: first occurrence, but structurally guaranteed to repeat at every
  `bd init`.
- Recovery / intervention: taken under the owner's bootstrap directive of
  2026-09-09. Prepended an explicit override ABOVE the generated block in
  `AGENTS.md` (the block is hash-delimited and bd may rewrite it, so editing inside
  it would not survive), and recorded the same rule as a named anti-pattern in
  `WORKSPACE_PROTOCOL.md`. Commit `9f23f72`.
- Outcome: not yet exercised — no seat has read the file at time of writing.
- Protocol candidate: make "override the generated `AGENTS.md` push mandate" an
  explicit step of repo bootstrap in `workspace-protocol.template.md`, rather than
  something each bootstrap rediscovers. Two other beads defaults deserve the same
  treatment: `bd remember` for persistent knowledge and the ban on TodoWrite both
  cut across room doctrine.
- Human decision needed: none.

## Codex seats silently run at `high` when a brief says `medium`

- Observation: the owner specified "codex sol (medium effort)" for one lane of the
  `pptx2html-llm` design round. Omitting `thinkingOptionId` on
  `codex-peer/gpt-5.6-sol` does NOT yield the model's own default — it yields
  `high`, twice over.
- Cause evidence: `~/.codex/peer.config.toml:10` pins
  `model_reasoning_effort = "high"`; and `~/.local/bin/codex-room-sync:145-157`
  rewrites the model catalogue, raising `default_reasoning_level` from `low` to
  `high` for any model supporting it — its own comment says *"paseo omits it unless
  a thinkingOptionId was set"*. Owner rule of 2026-08-10, "thinking floor is high".
- Suspected mechanism: the floor was introduced to stop seats silently reasoning at
  `low`. It has no exception for a later owner instruction that deliberately asks
  for less, and nothing surfaces the substitution.
- Impact: a lane the owner chose for a specific effort level runs at a different one
  and reports as if it had complied. In a heterogeneous council that is not a cost
  question — effort is part of what makes the lane a distinct evidence source.
- Anti-pattern: a standing config default overriding a specific instruction, with no
  signal at the point of use.
- Pattern status: first occurrence.
- Recovery / intervention: none taken on the config (it is owner-approved text and
  changing it would alter every Codex seat). Instead pinned the explicit
  `{"thinkingOptionId":"medium"}` in the repository's Routing table with the trap
  written out, and required the Lead to **verify the observed effort and report it**
  rather than assert compliance.
- Outcome: **RESOLVED 2026-09-09 23:15 +07, and my hypothesis was wrong in the
  useful direction.** An explicit Paseo `thinkingOptionId` DOES beat both the
  overlay and the patched catalogue default. Lane C ran at `medium` as instructed.
  Two independent sources agree: the Lead read the seat's own rollout
  (`~/.codex-runtime/peer/sessions/2026/09/09/rollout-*01a086f4*.jsonl`:
  `payload.effort = 'medium'`, `collaboration_mode.settings.reasoning_effort =
  'medium'`), and Paseo's `list_agents` independently reports
  `effectiveThinkingOptionId: "medium"` for agent `7a5cf345`. So the room's
  `high` floor is a **default**, not a ceiling — an owner instruction asking for
  less is satisfiable, and the Human decision I flagged below is moot.
  Correction to the Impact line above: the substitution risk is real only when
  `thinkingOptionId` is OMITTED. Stating it explicitly is sufficient, and that is
  now the durable rule for any brief naming an effort.
  Method note worth carrying: the Lead verified from the **seat's own rollout
  file**, not from Paseo's request view. That is the stronger source — the
  request view shows what was asked for, the rollout shows what the model was
  actually run with. Prefer it whenever a config layer could intervene.
- Protocol candidate: a floor that can be overridden silently should still announce
  itself — `codex-room-sync` logging the effort actually applied at launch would
  have made this a zero-cost check instead of a rollout-file dig. Weaker candidate
  now that the override is proven to work.
- Human decision needed: none — moot. The question was whether an explicit owner
  instruction can go BELOW the 2026-08-10 high floor. It can, mechanically, and it
  did.

### Addendum — OAuth lineage: the `shared` fallback is now itself BLANK (2026-09-09 23:07 +07)

Measured while staffing `pptx2html-llm`, by the same fingerprint probe as the
15:00 entry:

```
shared      accessFP=BLANK      refreshFP=BLANK      expiresAt=0
supervisor  accessFP=1752275195 refreshFP=92336d2f0b expiresAt=2026-09-10T06:37:55
lead        accessFP=fa51379bb7 refreshFP=487b0591d9 expiresAt=2026-09-10T06:48:09
peer        accessFP=fa51379bb7 refreshFP=487b0591d9 expiresAt=2026-09-10T06:48:09
```

- **New and material: the operator's shared entry (`Claude Code-credentials`) has
  been blanked.** Both prior repairs were "copy the shared credential into the blank
  profile". That recovery no longer exists — the source is gone. Any third
  occurrence must copy from a still-live profile instead, and the only independent
  lineage left is `supervisor`; using it would fold Supervisor into the same race
  the repair is meant to fix.
- `lead` and `peer` remain byte-identical, so the race is fully armed and the
  22:49 prediction still stands for **2026-09-10 06:48:09 +07**.
- Pattern status: **third data point on the same mechanism**, and the first that
  degrades the recovery path rather than just re-triggering the fault. The per-profile
  `/login` has now been deferred three times; each deferral has been cheaper than the
  fix only because the fix keeps not happening.
- Human decision needed: yes, and it is getting more expensive to defer — do the
  per-profile `/login` for `claude-lead` and `claude-peer` so each seat owns an
  independent OAuth session.

### RESOLVED — OAuth lineage race closed by construction, not repaired again (2026-09-09 23:37 +07)

Third occurrence was never reached. The owner directed the durable fix instead of a
fourth copy-repair: **every Claude seat now authenticates with
`CLAUDE_CODE_OAUTH_TOKEN`**, a one-year subscription token from
`claude setup-token`. Merged to `master` as `69f02dc`.

- **Why this ends the pattern rather than delaying it.** The defect was never
  "credentials expire"; it was **N copies of one refresh-token lineage rotating
  against each other**. A setup-token is a static bearer credential — nothing
  refreshes, so there is no lineage left to invalidate. The failure mode is
  removed, not made less likely. Every previous intervention in this notebook was
  a copy-repair with a predicted re-arm time; this is the first that has no
  re-arm.
- **The Keychain seeding block in `bin/claude-profile` is gone.** By tonight it was
  not merely dead but harmful: it seeded new profiles from the shared entry, and
  that entry is blank, so any new role profile would have been born dead — and the
  failure would have looked like a Paseo defect. Its recovery comment was stale in
  the same direction. Both flagged earlier today and now removed rather than
  re-flagged.
- **Fails closed on purpose.** If no token resolves, the launcher exits 3 instead of
  falling back to a `/login` credential. That fallback would work today and
  silently re-arm the race, which is exactly the class of bug this room keeps
  paying for.
- **The preflight finally exists.** `tests/smoke.sh` now resolves the token, checks
  its shape, and verifies no higher-precedence source (`ANTHROPIC_AUTH_TOKEN`,
  `ANTHROPIC_API_KEY`) is set. Proposed twice in this notebook after seats died
  mid-assignment; both new branches were verified to FAIL when they should, so it
  is not a check that always passes.
- **Method that actually settled it — a negative control on the credential itself.**
  Running the launcher with a well-formed but bogus token returned `401 OAuth
  access token is invalid`. Without that control, a successful probe would have
  proven nothing: the Keychain login was still present and would have served the
  request either way. A green auth probe with a working fallback in place is not
  evidence. This is the same positive/negative-control discipline that caught the
  four truncation errors, applied to auth.
- **Accepted cost, owner-directed for all roles**: a setup-token "can only make
  model requests", so seats lose Remote Control and claude.ai connectors — Notion,
  Gmail, Drive, Calendar, Excalidraw. Notion is in active use. Recommendation on
  record was to keep Supervisor on `/login` to preserve it; the owner chose all
  roles, twice. Local MCP servers are unaffected.
- **Residual, not covered by the fix**: seats already running at merge time keep the
  old Keychain credential, which still expires 2026-09-10 06:48:09 +07. The fix
  applies at launch. A replacement seat spawned after a death gets the token, so
  recovery is now clean even if the old race fires once more.
- **Operator error worth recording, mine.** The first attempt to commit this used
  `git commit -m "…"` with backticks in the message; bash ran the substitution and
  launched a real `claude setup-token` process that sat waiting on browser
  approval. No side effect — a setup-token saves nothing until approved, and the
  `.zshrc` token fingerprint was unchanged — but it is a live-credential command
  fired by a quoting mistake. **Commit messages containing backticks go through
  `git commit -F -` with a quoted heredoc, never `-m` inside double quotes.**
- Pattern status: **closed.** Reopen only if a seat authenticates with something
  other than the token, or if the token is revoked before its one-year term.

## Measuring across an event the agent cannot cause (2026-09-09)

- Supervisor briefed a probe to "test whether the volume identifier survives **reboot**." Flawed
  instruction: **a seat cannot reboot the machine** — it would kill itself mid-run — so the honest
  outcome would have been `NOT TESTED`, permanently, and the gap would have been recorded rather
  than closed.
- Lead's fix, worth reusing: split the probe into **`--record` / `--verify`**. `--record` writes
  the current identifiers (and, opportunistically, a set of freshly allocated inode numbers) to a
  durable file now; `--verify` re-reads and compares after any later boot. The probe reports
  `NOT TESTED (pending reboot)` **with the exact verify command**, and the reading completes for
  free at the machine's next ordinary restart.
- It closed **two** stated gaps at once — the volume identifier across reboot, and an
  inode-reuse-across-reboot reading an earlier probe had explicitly left open. Neither required
  anyone to force a reboot.
- Generalisation: when a measurement depends on an event outside the agent's authority — reboot,
  a deploy, a certificate arriving, a user action — **do not accept `NOT TESTED`; leave a durable
  record and a one-command verifier.** The gap converts from permanent to pending.
- Supervisor lesson: I wrote an instruction a seat could not physically satisfy, and the Lead did
  not simply comply-and-fail or push back with the objection alone — it returned the objection
  **with the redesign attached**. That is the response worth reinforcing, and it only happens if
  the brief invites correction rather than demanding compliance.

## Verifying a sealed council seal without reading the seats

- Observation: on `pptx2html-llm` round 1 all three lanes shared one checkout, so Lane
  A's report sat on disk (23:29) before Lanes C (23:35) and B (23:37) submitted. The
  seal was behavioural — `protocol/council.md` defines `sealed` that way — so it was
  breakable with one `cat` and nothing would have recorded it.
- Cause evidence: `docs/council/lane-a-source-and-inheritance.md` mtime precedes both
  other lanes' commits (`1c3b349`, `3e0b8e1`).
- **Method that settled it cheaply, and the distinction that makes it work**: grep the
  later reports for references to the earlier lane, then classify each hit. A brief
  that asks each lane to *state its requirements on the other axes* guarantees
  cross-lane mentions, so hit count alone proves nothing — the discriminator is
  **direction**. Requirements and open questions ("Lane A to confirm", "requirement
  A1", "wrong provenance from Lane A" as a listed failure mode) are the brief being
  obeyed. Citing another lane's *conclusion* as settled would be the breach. On this
  round all 21 hits across B and C were the former, and B labelled the very claims it
  routed to A as `OPINION` — the opposite of having peeked.
- Impact if skipped: a broken seal turns three independent evidence streams into one
  correlated one, and convergence then reads as confirmation when it is contagion.
  Nothing else in the topology would surface it.
- Anti-pattern avoided: I nearly reported "terminal sentinel absent" off a guessed
  grep pattern that returned 0. That is the same shape as the truncation failures
  logged above — a negative from an unvalidated method. Checked the actual file tails
  instead; the reports carry the SEAT REPORT fields, and report shape is the Lead's
  acceptance call, not mine.
- Pattern status: first occurrence of the check; the seal-on-shared-checkout structure
  will recur in every council that is not given separate worktrees.
- Protocol candidate: `protocol/council.md` could name this as the seal audit — one
  grep, classify by direction — so a Lead or Supervisor is not left choosing between
  trusting the seal and reading the seats. Worktree isolation makes the seal
  structural instead, at the cost of setup; worth stating the trade rather than
  leaving it implicit.
- Human decision needed: none.
