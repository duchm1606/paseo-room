# Orchestration Philosophy

> Distilled 2026-08-06 from the Demonthorn/vhlam corpus (Demonthorn_6512
> bundle, #ai-lười-chat-tổng thread, agent-orchestration deep-dive, the
> live Echo workspace protocol) and from rulings made while adapting it
> to this harness. Use this document to audit the current architecture:
> every law below names its enforcement surface. TARGET.md is the spec;
> this is the "why" and the checklist.

## 1. Axioms

1. **Protect attention and independent judgment.** Every structural
   choice exists to keep each agent's attention on its own job and its
   judgment uncorrelated with its neighbors'. Coordination state and
   implementation state never share one context.
2. **One control plane.** Paseo seats are the only delegation surface.
   No agent spawns helpers inside its own session. An agent that can
   quietly fork workers becomes an unauditable second orchestrator.
3. **Minimal harness — "system càng ít, model càng mạnh."** Every rule,
   role, and skill in context taxes the model. Add prose only for
   observed friction, in the narrowest owning surface. Never create a
   role, ceremony, or variant before the pain point exists.
4. **Code is truth; plans are provisional maps.** A plan is guidance
   for an agent that will re-derive reality from the repository. Never
   treat plan text, file lists, or lifecycle status as verdicts.
5. **Evidence over status.** FINISH/IDLE/ERROR events, green tests, and
   agreement counts are attention signals, never acceptance. Accepting
   requires the exact candidate identity and personally observed
   verification.
6. **Denials are routing information.** A gate refusing an action tells
   the agent where the work actually belongs, not that the work is
   impossible.

## 2. Topology

```
Human (owner)
  └── Supervisor  — owner's standing chat interface + cross-workspace observer
        └── Lead  — one per project; binding technical authority ("god of its workspace")
              └── Peer(s) — ONE profile; disposition set per brief
                            (Engineer / Architect / Reviewer / Scout / auditor / shadow)
```

- **Human → Lead contact is limited to the initial handoff.** Mid-task
  questions and decisions flow through the Supervisor, which relays
  settled decisions verbatim — it protects the Lead's coordination
  attention and is not a decision layer.
- **Lead never implements** — not even tiny tasks. Its attention is
  loaded with coordination state, and every change needs a reviewer who
  is not its implementer. Lead is itself the first review layer on
  every handback.
- **Peer has no orchestration authority** and never learns control-plane
  mechanics. It owns judgment inside an assigned outcome boundary: it
  may reject a false premise and reopen a material constraint, but
  independent judgment is not performative dissent — agreement is valid
  when evidence supports it.
- **Supervisor advises the Lead, never commands workers.** It evaluates
  coordination, not implementation correctness. It never scores agents
  by agreement, never runs project validation, never owns acceptance.
  On-demand, not polling; heartbeat only during high-risk phases.

## 3. Delegation laws

- **Neutral outcome briefs.** A brief states outcome, ownership
  boundary, exclusions, authority, and verification — never a
  prescribed conclusion, never the Lead's preferred answer.
- **One writer per moving scope.** Concurrent writers require isolated
  worktrees. Review only an exact commit or deterministic snapshot.
- **Anti-option-menu law.** Writable-owner briefs explicitly forbid
  stopping to offer the Lead a menu of options. A genuinely
  cross-boundary decision is one short yes/no question.
- **Plans are written for agents, not humans.** Say so explicitly: the
  executor is one strong agent working hours, not a team working
  months. Forbid slicing for compilability — a slice is legitimate only
  if it is independently acceptable; a mid-plan slice need not compile,
  run, or test. Compile-bridge/compatibility layers between slices are
  the canonical failure.
- **Escalation vocabulary** (a peer's only exits besides delivery):
  `REOPEN_REQUEST` (premise fails) · `DEPENDENCY_REQUEST` (unowned
  prerequisite) · `BLOCKED` (no safe progress). The Lead answers each
  with a concrete ruling.

## 4. Review and acceptance ladder

Ceremony is risk-selected, never default:

| Tier | Shape |
|---|---|
| Tiny / bounded | one Engineer, thin brief; Lead counter-review; independent Reviewer optional |
| Cross-module / lifecycle-sensitive | Architect (read-only) → Engineer → one independent Reviewer on a stable candidate → Lead verdict; corrections return to the same Engineer session; loop |
| Architecture lock-in / hard cases | **dual design / dual review**: two sealed seats with distinct mandates, ideally across model tiers or providers, on one frozen candidate; full review adds a third lane — the `codex-review` OCR delegation seat on the same candidate (rule-based evidence, never the macro review) |

- Findings reconcile as `CONFIRM / PARTIAL / CHALLENGE / BLOCK` before
  correction; acceptance is `ACCEPT / REVISE / WAIT`.
- **Two rounds in one finding family → stop patching symptoms and hunt
  the shared missing mechanism.** (The "heavy parachute" law: two
  findings that converge reveal one foundation flaw.)
- Council mechanics (sealed / anonymous / shadow) are orthogonal tools,
  not a package; seat count and provider count create no authority —
  two models agreeing does not make an unevidenced claim true.
- A Reviewer is always a fresh session with a neutral brief, never the
  implementer, and a verdict auditor must not have participated earlier
  in the case.

## 5. Context, memory, momentum

- **Context budget:** when a long-context owner exceeds ~45% of its
  window at handback, compact it or start a fresh owner. Never silently
  continue a context-heavy owner.
- **Memory is supervisor-scoped.** Lead and Peer never write the
  auto-memory store; durable findings live in handbacks and closing
  reports. (Independently confirmed by Demonthorn's bootstrap doc:
  "Supervisor has memory enabled, does not own project acceptance.")
- **Momentum recovery** is a Supervisor job on a cheap model: rebuild a
  broken workstream's thread from git history and session history, then
  restart the Lead with a bounded handoff.
- **Don't fork a Lead session to get a second opinion** — the fork
  inherits every bias. Ask the Supervisor (neutral, cross-cutting) or
  convene sealed seats.

## 6. Skills

- **Macro/micro/strategy split:** Lead holds coordination skills; Peer
  holds engineering skills; Supervisor holds strategy/governance
  skills. Skills that orchestrate their own subagent fleets are banned
  on every seat.
- Shared skill store, role-filtered by gate — one source of truth, no
  per-role skill copies.
- Keep the base instruction minimal; split optional domains (e.g.
  frontend design) into skills loaded on demand.

## 7. Development doctrine (greenfield / pre-ship)

- **Hard cut:** exactly one live contract and implementation path;
  schema version stays 1 until first public shipment — replace v1
  content, never add v2. No shims, adapters, dual read/write, migration
  paths for dev data, or fallback semantics. Fail fast, fail closed.
- **Test discipline:** tests protect settled contracts, they do not
  choose architecture. Never keep production API/state whose only
  consumer is a test. After a hard cut, derive negative cases from
  current constants (`WIDTH ± 1`), never from deleted names; no
  tombstone tests, no legacy blacklists.
- **Proof is best-effort and subordinate:** never reshape APIs, weaken
  boundaries, or retain dormant machinery to make tests, benchmarks, or
  proof easier. Agents over-test by training reward — expect it, gate
  it, and periodically run proof-debt audits.
- "Pressure from code beats pressure from docs": ten bad tests breed an
  eleventh regardless of doctrine — physically remove debris
  (repo-refresh), don't just legislate against it.

## 8. Outside-the-room tooling

- **Ultra-review** (max-recall N-scout bug hunt) is the owner's weapon,
  fired from an ordinary session — never a seat skill. Cadence: once at
  plan closure by default; mid-plan only at a stable checkpoint that
  completes an end-to-end capability, freezes a foundation, or crosses
  a hard-to-reverse boundary. Findings enter the room through the Lead
  as a verification brief; treat every finding as a possible false
  positive and check for convergence on a missing mechanism.
- Brief active peers only at handback; never interrupt a working seat.

## 9. Anti-pattern catalog (fast recall)

micro-scoped work orders · pre-solving in briefs · shadowing an active
owner · staffing roles by template · review without material
uncertainty · duplicate proof · option-menu rituals · treating
lifecycle status as truth · permission ceremonies instead of fixing the
seat · context-burning polling · returning Lead-sized decisions to the
owner · compile-bridge slices · version-bump compatibility reflex ·
tombstone tests · council-as-default (process friction eats half the
tokens) · scout theater (semantic search before `rg`) · plan-file
litter · silently continuing a context-heavy owner

## 10. Audit checklist — law → enforcement surface

Verify each row when auditing the architecture; a law with no living
enforcement surface is a slogan.

| Law | Enforced by | Verify |
|---|---|---|
| Single control plane | provider `disallowedTools` + `hooks/role-gate.sh` (Task/Agent/Workflow deny) | seat attempts Task → deny JSON |
| Role identity survives compaction | SessionStart inject hook (`inject-profile.sh`) | resume a seat, profile block present |
| Skill matrix (macro/micro/strategy) | `role-gate.sh` allow-lists keyed on `ROOM_ROLE` (flipped from deny-lists 2026-08-18) | invoke off-role skill → deny with routing reason |
| Fleet-spawning skills banned on seats | `role-gate.sh` `GLOBAL_DENY` | ultra-review/review-swarm from any seat → deny |
| Supervisor-only memory | `role-gate.sh` Write/Edit deny on `~/.claude/projects/` for lead/peer | lead writes memory file → deny (Bash bypass = residual risk, soft law covers) |
| Human↔Lead only at handoff | supervisor.md (standing chat interface) + lead.md (closing report via Supervisor) | read profiles |
| Lead never implements | lead.md + TARGET law 6 | read profile; watch a tiny task get routed |
| Neutral briefs / anti-option-menu | workspace-protocol.template.md "Brief discipline" | check per-repo WORKSPACE_PROTOCOL.md exists and carries it |
| Escalation + reconcile + verdict vocab | lead.md, peer.md, protocol/states.md, handback.md | read profiles/protocol |
| Assignment envelope carries stop condition, active-owner check, mutation vs external-effect split, acceptance owner | protocol/context-pack.md skeleton | read a live brief: the four lines are present or collapsed, never absent |
| Council ends in an owned rationale, not a majority | protocol/council.md artifacts (question / seat report / reconcile) | reconcile output names why the minority view was rejected |
| Layered status; one PASS never covers an untested layer | lead.md CLOSING REPORT; protocol/lead-operations.md | closing reports show SOURCE/ARTIFACT/INSTALLED/LIVE/RESIDUAL verdicts |
| Supervisor intervention = attention packet | supervisor.md "Advise without taking over" | a message to Lead carries evidence + unknown + open question, no command |
| Handoff ≠ handback; break-before-make on owner change | protocol/handoff.md (packet + Lead replacement receipt); lead.md CADENCE; supervisor.md ops | a Lead replacement leaves a receipt in the notebook; no two seats `working` on one scope |
| Review ladder + dual alias | workspace-protocol.template.md task classes; council.md | read protocol |
| Context budget ~45% | workspace-protocol.template.md "Context budget" | per-repo protocol carries it; Lead compacts/replaces owners |
| Ultra-review cadence | workspace-protocol.template.md "Ultra-review gate" | reports appear only at legit checkpoints |
| Hard cut + test discipline | per-repo doctrine (CLAUDE.md / dev policy) — NOT yet global | check each greenfield repo carries it |
| Notebook aggregation | SUPERVISOR_NOTEBOOK.md Active-patterns table | rows gain `observed→applied→adopted` states over time |
| Cheap-model economics | supervisor provider Sonnet entry; scouts on Haiku | config.json models; ultra-review SKILL.md |
| MCP surface per role | config.json `injectIntoProviders` (lead, supervisor) + peer `disallowedTools mcp__paseo` | config.json |

## Known open items

- `enabledPlugins` via `--settings` needs one live-seat verification.
- `$ultra-review-receive` companion skill not yet obtained; interim
  receive-flow = peer verification brief + architecture-premise-audit.
- Hard-cut/test doctrine lives per-repo; no global enforcement surface.
- Bash-redirection bypass of the memory gate is accepted residual risk.
