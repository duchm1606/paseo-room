#!/usr/bin/env bash
# Session telemetry (Herdr curriculum, Lesson 18): fast, atomic-append,
# never blocks, no orchestration logic. No-op outside the profile system.
[ -z "${ROOM_ROLE:-}" ] && exit 0

EVENT="${1:-unknown}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/telemetry"
mkdir -p "$DIR"

printf '{"ts":"%s","profile":"%s","event":"%s","session":"%s","cwd":"%s"}\n' \
  "$(date -u +%FT%TZ)" \
  "$ROOM_ROLE" \
  "$EVENT" \
  "${CLAUDE_SESSION_ID:-}" \
  "$PWD" \
  >> "$DIR/${ROOM_ROLE}.jsonl"

exit 0
