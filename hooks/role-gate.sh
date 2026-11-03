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
# installed and ~/.claude/profiles/settings.json disables them besides, and
# disableBundledSkills removes Claude Code's built-in skills, so a seat sees
# only project skills (<repo>/.claude/skills) and room skills (the profile's
# skills symlink -> <room>/skills). Droid seats still list Droid's built-ins;
# these lists deny them.
# A skill from a disabled plugin is unreachable regardless of these lists.
set -euo pipefail

payload="$(cat)"
tool="$(jq -r '.tool_name // empty' <<<"$payload")"
TELEMETRY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/telemetry.sh"

# Every denial is logged (telemetry/<role>.jsonl, event `deny`), so a seat
# that keeps reaching for a missing skill shows up in the record.
deny() {
  { [ -f "$TELEMETRY" ] && bash "$TELEMETRY" deny <<<"$payload"; } >/dev/null 2>&1 || true
  jq -cn --arg reason "$1" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$reason}}'
  exit 0
}

# Owner-approved, exact launch-root grants live in the room, never in an
# arbitrary project config. granted <role> <name> succeeds only when the
# canonical session cwd is a registry key granting <name> to <role>.
grants="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/protocol/workspace-skill-grants.json"
workspace_cwd="$(jq -r '.cwd // empty' <<<"$payload")"
canonical_cwd=""
case "$workspace_cwd" in
  /*) canonical_cwd="$(cd -- "$workspace_cwd" 2>/dev/null && pwd -P)" || canonical_cwd="" ;;
esac
granted() {
  [ -n "$canonical_cwd" ] && [ -f "$grants" ] || return 1
  jq -e --arg cwd "$canonical_cwd" --arg role "$1" --arg skill "$2" \
    '(.[$cwd][$role] // []) | if type == "array" then index($skill) != null else false end' \
    "$grants" >/dev/null 2>&1
}

case "$tool" in
  Task|Agent|Workflow)
    deny "In-session subagents are disabled: Paseo seats are the only delegation surface. Lead routes work to a Peer seat; a Peer returns out-of-scope work to Lead with evidence instead of spawning helpers."
    ;;
  Bash)
    # OCR (open-code-review) is denied to every seat. Its raw output is noisy
    # for coordination, and implementers must not self-review with it.
    # Word-boundary match on the `ocr` command.
    # Exception (owner directive 2026-10-15): a Claude Peer whose canonical
    # cwd is granted `open-code-review:delegate-review` may run delegation
    # mode only (`ocr delegate|d preview|rule`, plus help/version). Every
    # `ocr` token in the command must be such a call; `ocr review` and the
    # rest of the CLI stay denied. Droid seats (ROOM_GATE_HOST=droid) never
    # get the exception.
    case "${ROOM_ROLE:-}" in
      lead|peer|supervisor)
        cmd="$(jq -r '.tool_input.command // empty' <<<"$payload")"
        ocr_any='(^|[;&|[:space:]("`])ocr([[:space:]]|$)'
        ocr_ok='(^|[;&|[:space:]("`])ocr[[:space:]]+((delegate|d)[[:space:]]+(preview|rule)|((delegate|d)[[:space:]]+)?(--help|-h|--version))([[:space:]]|$)'
        if grep -qE "$ocr_any" <<<"$cmd"; then
          if [ "${ROOM_ROLE:-}" = peer ] && [ "${ROOM_GATE_HOST:-}" != droid ] \
              && granted peer open-code-review:delegate-review \
              && [ "$(grep -oE "$ocr_any" <<<"$cmd" | wc -l)" -eq "$(grep -oE "$ocr_ok" <<<"$cmd" | wc -l)" ]; then
            exit 0
          fi
          deny "OCR is denied on this seat. Only a Claude Peer at a workspace granted open-code-review:delegate-review may run 'ocr delegate preview|rule' (delegation mode, host model reviews); 'ocr review' and other OCR commands stay denied. Lead: route the review to that Peer lane. Peer: return the review need to Lead with evidence."
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

# Exact launch-root grants (see granted above) supplement skills only:
# earlier delegation, OCR, memory and global skill denials remain
# authoritative.
if granted "$profile" "$skill"; then
  exit 0
fi

# Each list names room skills (skills/) only; workspace-specific project
# skills come through the grants registry.

# Lead: coordination, routing, acceptance. Never implements, never pre-solves,
# never runs intake — it receives a scope already locked by the owner.
LEAD_ALLOW=" repo-refresh triple-review council "

# Peer: engineering inside one assigned scope. No coordination, no intake,
# no harness configuration — those belong to Lead or Supervisor.
# test-proof-debt-audit serves the Reviewer and Auditor dispositions;
# browser-harness is the one browser for every Peer host.
PEER_ALLOW=" research test-proof-debt-audit browser-harness "

# Supervisor: governance, observation, protocol optimization, Paseo operation.
# Never project code, never project validation.
SUPERVISOR_ALLOW=" grilling architecture-premise-audit test-proof-debt-audit "

# Droid's built-in browser: name the room's browser so the seat switches
# instead of retrying.
if [ "$base" = agent-browser ] && [ "$profile" = peer ]; then
  deny "Skill 'agent-browser' is not available on this seat. Use the browser-harness skill for browser work."
fi

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
