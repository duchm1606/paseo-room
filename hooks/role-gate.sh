#!/usr/bin/env bash
# PreToolUse gate: Paseo seats are the only delegation surface.
# 1) Hard-block in-session subagents (Task/Agent/Workflow) for every profile.
# 2) Enforce the per-role skill matrix keyed on ROOM_ROLE.
#
# ALLOW-LIST model (flipped from deny-list on 2026-08-18, owner directive).
# A seat may run only the skills named in its role list; everything else is
# denied, including skills installed later. Sessions without ROOM_ROLE
# (ordinary human sessions) stay untouched — the gate governs seats only.
#
# Seat skill surface is narrow by construction: seats run in isolated
# profile homes (~/.claude/profiles/claude-<role>) where no plugins are
# installed and ~/.claude/profiles/settings.json disables them besides, so a seat sees
# only project skills (<repo>/.claude/skills), room skills (the profile's
# skills symlink -> <room>/skills), and built-ins.
# A skill from a disabled plugin is unreachable regardless of these lists.
set -euo pipefail

payload="$(cat)"
tool="$(jq -r '.tool_name // empty' <<<"$payload")"

deny() {
  jq -cn --arg reason "$1" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$reason}}'
  exit 0
}

case "$tool" in
  Task|Agent|Workflow)
    deny "In-session subagents are disabled: Paseo seats are the only delegation surface. Lead routes work to a Peer seat; a Peer returns out-of-scope work to Lead with evidence instead of spawning helpers."
    ;;
  Bash)
    # OCR (open-code-review) is operated only by the codex-review seat. Its
    # raw output is noisy for coordination, and implementers must not
    # self-review with it. Word-boundary match on the `ocr` command.
    case "${ROOM_ROLE:-}" in
      lead|peer|supervisor)
        cmd="$(jq -r '.tool_input.command // empty' <<<"$payload")"
        if grep -qE '(^|[;&|[:space:]("`])ocr([[:space:]]|$)' <<<"$cmd"; then
          deny "OCR is operated only by the dedicated codex-review seat, which returns distilled findings to Lead. This seat does not run 'ocr'. Lead: route the review to the codex-review provider. Peer: return the review need to Lead with evidence."
        fi
        ;;
    esac
    exit 0
    ;;
  Write|Edit|MultiEdit|NotebookEdit)
    # Session memory is supervisor-scoped (TARGET law): lead and peer must
    # not write into the shared auto-memory store.
    case "${ROOM_ROLE:-}" in
      lead|peer)
        target="$(jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' <<<"$payload")"
        case "$target" in
          "$HOME/.claude/projects/"*|"$HOME/.claude/profiles/"*"/projects/"*)
            deny "Session memory is supervisor-scoped. Durable findings belong in the handback (or repo docs when the brief says so), not in the auto-memory store."
            ;;
        esac
        ;;
    esac
    exit 0
    ;;
  Skill) ;;
  *) exit 0 ;;
esac

skill="$(jq -r '.tool_input.skill // empty' <<<"$payload")"
[ -n "$skill" ] || exit 0
base="${skill##*:}"
profile="${ROOM_ROLE:-}"

# No profile = ordinary human session. The gate governs seats only.
[ -n "$profile" ] || exit 0

# Skills that orchestrate their own subagent fleets - banned on every seat,
# checked before the allow-lists so the specific reason survives.
GLOBAL_DENY=" review-swarm code-review ultra-review "
case "$GLOBAL_DENY" in
  *" $base "*)
    deny "Skill '$skill' orchestrates its own subagent fleet, which conflicts with the single-control-plane law. Reviews run as a Peer seat with a Reviewer disposition."
    ;;
esac

# Lead: coordination, routing, acceptance. Never implements, never pre-solves,
# never runs intake — it receives a scope already locked by the owner.
LEAD_ALLOW=" visual-explainer domain-modeling triage to-issues
 repo-refresh triple-review ultra-review "

# Peer: engineering inside one assigned scope. No coordination, no intake,
# no harness configuration — those belong to Lead or Supervisor.
PEER_ALLOW=" implement tdd prototype diagnosing-bugs simplify-code simplify
 codebase-design improve-codebase-architecture domain-modeling research
 frontend-design pptx dataviz visual-explainer claude-api run security-review "

# Supervisor: governance, observation, protocol optimization, Paseo operation.
# Never project code, never project validation.
SUPERVISOR_ALLOW=" visual-explainer writing-great-skills teach goal-distill
 triage schedule loop update-config keybindings-help
 fewer-permission-prompts init claude-api
 paseo-supervisor architecture-premise-audit
 test-proof-debt-audit "

allow=""
case "$profile" in
  lead) allow="$LEAD_ALLOW" ;;
  peer) allow="$PEER_ALLOW" ;;
  supervisor) allow="$SUPERVISOR_ALLOW" ;;
  *) exit 0 ;;
esac

# Normalize whitespace so multi-line lists match on a single-space boundary.
allow=" $(tr -s '[:space:]' ' ' <<<"$allow" | sed 's/^ *//;s/ *$//') "

case "$allow" in
  *" $base "*) exit 0 ;;
esac

case "$profile" in
  lead)
    deny "Skill '$skill' is not on the Lead allow-list. This denial is routing information: implementation-shaped work belongs in a Peer brief, and intake-shaped work (PRD, scope, grilling) belongs to the owner before the issue reaches you. Lead may run: $allow"
    ;;
  peer)
    deny "Skill '$skill' is not on the Peer allow-list. Coordination-, intake-, and harness-shaped work belongs to Lead or Supervisor; return the concern to Lead as a request with evidence. Peer may run: $allow"
    ;;
  supervisor)
    deny "Skill '$skill' is not on the Supervisor allow-list. Engineering-shaped work belongs in a workspace seat, not in supervision; a mission that needs more is an explicit owner grant in the mission prompt. Supervisor may run: $allow"
    ;;
esac
