#!/usr/bin/env bash
# Wiring + generation smoke test. No daemon calls, no model calls.
set -uo pipefail

fail=0
die() { printf 'FAIL: %s\n' "$*"; fail=1; }

ROOM="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 1. The room lives inside the daemon home, as a git checkout.
[ "$ROOM" = "$HOME/.paseo/orchestration" ] \
  || die "room checkout is at $ROOM, expected ~/.paseo/orchestration"
[ -d "$ROOM/.git" ] || die "room checkout is not a git repository"

# 2. Scripts parse.
bash -n "$ROOM/bin/claude-profile" "$ROOM/bin/claude-lead" "$ROOM/bin/claude-peer" \
  "$ROOM/bin/claude-supervisor" "$ROOM/bin/codex-room" "$ROOM"/hooks/*.sh \
  || die "bash -n on launchers/hooks"
python3 -m py_compile "$ROOM/bin/codex-room-sync" || die "codex-room-sync py_compile"

# 3. Every provider command in the live wiring table stays in orchestration/bin.
outside="$(jq -r '.agents.providers | to_entries[] | select(.value.command) | .value.command[0]' \
  "$HOME/.paseo/config.json" | grep -v "^$HOME/.paseo/orchestration/bin/")"
[ -z "$outside" ] || die "provider command outside orchestration/bin: $outside"

# 4. Codex runtime generation per role.
for role in supervisor lead peer peer-zen review; do
  if ! "$ROOM/bin/codex-room-sync" "$role" 2>/dev/null; then
    die "codex-room-sync $role"
    continue
  fi
  rt="$HOME/.paseo/codex-runtime/$role"
  grep -q '^developer_instructions = """' "$rt/config.toml" || die "$role: no developer_instructions"
  grep -q '^multi_agent = false' "$rt/config.toml" || die "$role: multi_agent not disabled"
  jq -e '[.models[].multi_agent_version] | all(. == null)' \
    "$rt/model-catalog.no-native-agents.json" >/dev/null \
    || die "$role: catalog still advertises native agents"
done
grep -q 'Room role: Peer' "$HOME/.paseo/codex-runtime/peer-zen/config.toml" \
  || die "peer-zen: inherited peer instructions missing"
# Codex itself creates a real skills/.system dir in every CODEX_HOME; the review
# seat must merely never link the operator's default skills/plugins.
[ ! -L "$HOME/.paseo/codex-runtime/review/skills" ] \
  || die "review seat must not link default skills"
[ ! -L "$HOME/.paseo/codex-runtime/review/plugins" ] \
  || die "review seat must not link default plugins"

# 5. Claude seat profiles seeded (created on first launch; check when present).
for role in lead peer supervisor; do
  p="$HOME/.paseo/claude-profiles/claude-$role"
  [ -d "$p" ] || continue
  [ "$(readlink "$p/settings.json")" = "$ROOM/profiles/settings.json" ] \
    || die "claude-$role: settings.json not linked to room profile settings"
  [ -L "$p/skills" ] || die "claude-$role: skills symlink missing"
done

if [ "$fail" -eq 0 ]; then
  echo SMOKE_OK
fi
exit "$fail"
