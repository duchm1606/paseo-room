#!/usr/bin/env bash
# notify-on-stop.sh: Hook run when an agent finishes its turn (Claude Code Stop hook).
# If a Lead finishes a background turn containing a report or pending question
# but failed to explicitly send it to the Supervisor, this hook auto-wakes the Supervisor.

[ "${ROOM_ROLE:-}" = "lead" ] || exit 0

command -v paseo >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

# Locate active supervisor for the current workspace/host
sup_id="$(paseo ls --json 2>/dev/null | jq -r '.[] | select(.provider | startswith("supervisor")) | select(.status != "closed") | .id' | head -n 1)"
[ -n "$sup_id" ] || exit 0

# Check the tail of the current lead session to see what just happened
lead_project_dir="$HOME/.claude/profiles/claude-lead/projects"
[ -d "$lead_project_dir" ] || exit 0

latest_jsonl="$(find "$lead_project_dir" -name "*.jsonl" -type f -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -n 1 | awk '{print $2}')"
[ -n "$latest_jsonl" ] && [ -f "$latest_jsonl" ] || exit 0

# Inspect the last assistant message
last_tail="$(tail -n 30 "$latest_jsonl" 2>/dev/null || true)"

# Check if the turn output looks like a report, phase gate, or pending question
is_report_or_gate=false
if grep -q -E "CLOSING REPORT|PHASE GATE|HANDBACK|báo cáo|nghiệm thu" <<<"$last_tail"; then
  is_report_or_gate=true
elif grep -q -E "\?[[:space:]]*\"?[[:space:]]*$" <<<"$last_tail"; then
  # Ends with a question (e.g. asking "you" for go-ahead)
  is_report_or_gate=true
fi

[ "$is_report_or_gate" = true ] || exit 0

# Check if paseo send was already executed in this turn (avoid duplicate wake-up)
if grep -q "paseo send" <<<"$last_tail"; then
  exit 0
fi

# Send wake-up signal to Supervisor
lead_id="$(paseo ls --json 2>/dev/null | jq -r --arg sid "${CLAUDE_SESSION_ID:-}" '.[] | select(.provider | startswith("lead")) | select(.status == "running" or .status == "idle") | .id' | head -n 1)"
[ -n "$lead_id" ] || lead_id="lead"

paseo send "$sup_id" "[Auto-wake from hook] Lead ($lead_id) finished a background turn with a report or question without sending. Please inspect lead logs." >/dev/null 2>&1 || true

exit 0
