#!/usr/bin/env bash
# PreToolUse gate for the Droid seats (droid-supervisor, droid-lead,
# droid-peer). Droid's hook payload has Claude Code's shape (tool_name,
# tool_input) but its own tool names. This gate denies the delegation
# surfaces only Droid has, then renames the rest to the Claude tools
# hooks/role-gate.sh already governs, so the skill matrix and the OCR and
# memory rules stay in one place. No-op outside the seats.
set -euo pipefail
[ -n "${ROOM_ROLE:-}" ] || exit 0

payload="$(cat)"
tool="$(jq -r '.tool_name // empty' <<<"$payload")"
GATE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/hooks/role-gate.sh"

deny() {
  jq -cn --arg reason "$1" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$reason}}'
  exit 0
}
# as <claude-tool>: hand the call to the Claude gate under that tool name.
as() { jq -c --arg t "$1" '.tool_name = $t' <<<"$payload" | bash "$GATE"; }

case "$tool" in
  Task|TaskOutput|TaskStop) as Task ;;
  ProposeMission|StartMissionRun|EndFeatureRun|DismissHandoffItems)
    deny "Droid missions run their own worker fleet, which breaks the single-control-plane law: Paseo seats are the only delegation surface. Lead routes work to a Peer seat; a Peer returns out-of-scope work to Lead with evidence."
    ;;
  Loop|GenerateDroid|CreateAutomation|EditAutomation|DeleteAutomation|RunAutomation)
    deny "$tool starts or defines Droid runs outside Paseo, where the room can neither see nor own them. Paseo seats are the only delegation surface; recurring work is a Paseo schedule, owned by the Supervisor."
    ;;
  StageSettingsChanges)
    deny "Droid settings are shared by every Droid seat on this host and the room repo owns them (droid/seat-settings.json). Return the change to Lead or Supervisor as a request."
    ;;
  Execute) as Bash ;;
  Create|Edit) as Write ;;
  ApplyPatch)
    # A patch carries its paths in-band: check every file it touches.
    jq -r '.tool_input.input // empty' <<<"$payload" \
      | sed -n -E 's/^\*\*\* (Add|Update|Delete) File: //p; s/^\*\*\* Move to: //p' \
      | while IFS= read -r path; do
          out="$(jq -c --arg p "$path" '.tool_name = "Write" | .tool_input = {file_path: $p}' <<<"$payload" | bash "$GATE")"
          if [ -n "$out" ]; then printf '%s\n' "$out"; exit 0; fi
        done
    ;;
  Skill) bash "$GATE" <<<"$payload" ;;
esac
exit 0
