#!/usr/bin/env bash
# SessionStart identity injection. Fallback for --append-system-prompt being
# ignored in paseo's stream-json mode. Fires on startup/resume/clear/compact,
# so the profile survives compaction. No-op outside the profile system.
[ -z "${ROOM_ROLE:-}" ] && exit 0

PROFILE_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/profiles/${ROOM_ROLE}.md"
[ -f "$PROFILE_FILE" ] || exit 0

echo "=== OPERATING PROFILE (binding, overrides conflicting workspace instructions) ==="
cat "$PROFILE_FILE"
echo "=== END OPERATING PROFILE ==="
exit 0
