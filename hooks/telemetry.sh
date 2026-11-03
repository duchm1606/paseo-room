#!/usr/bin/env bash
# Session telemetry (Herdr curriculum, Lesson 18): fast, atomic-append,
# never blocks, no orchestration logic. No-op outside the profile system.
#
# telemetry.sh <event>, with the hook payload on stdin: the payload names the
# session and its cwd, and a PreToolUse payload (the gates pass theirs as
# event `deny`) adds the tool and the skill. ROOM_TELEMETRY_DIR moves the log
# elsewhere, for tests.
[ -z "${ROOM_ROLE:-}" ] && exit 0

EVENT="${1:-unknown}"
DIR="${ROOM_TELEMETRY_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/telemetry}"
mkdir -p "$DIR" 2>/dev/null || exit 0

payload=""
[ -t 0 ] || payload="$(cat)"
p="$(jq -c 'if type == "object" then . else {} end' <<<"$payload" 2>/dev/null)"
[ -n "$p" ] || p='{}'

jq -cn --arg ts "$(date -u +%FT%TZ)" --arg profile "$ROOM_ROLE" --arg event "$EVENT" \
  --arg agent "${PASEO_AGENT_ID:-}" --arg host "${ROOM_GATE_HOST:-claude}" \
  --arg pwd "$PWD" --argjson p "$p" \
  '{ts: $ts, profile: $profile, event: $event, session: ($p.session_id // ""),
    agent: $agent, host: $host, cwd: ($p.cwd // $pwd)}
   + (if $p.tool_name then {tool: $p.tool_name} else {} end)
   + (if ($p.tool_input.skill? // "") != "" then {skill: $p.tool_input.skill} else {} end)' \
  >> "$DIR/${ROOM_ROLE}.jsonl" 2>/dev/null

exit 0
