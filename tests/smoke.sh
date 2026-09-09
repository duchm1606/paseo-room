#!/usr/bin/env bash
# Wiring + generation smoke test. No daemon calls, no model calls.
set -uo pipefail

fail=0
die() { printf 'FAIL: %s\n' "$*"; fail=1; }

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RT="$REPO/runtime"

# 1. Scripts parse.
bash -n "$RT/bin/claude-profile" "$RT/bin/claude-lead" "$RT/bin/claude-peer" \
  "$RT/bin/claude-supervisor" "$RT/bin/codex-room" "$RT"/hooks/*.sh \
  || die "bash -n on launchers/hooks"
python3 -m py_compile "$RT/bin/codex-room-sync" || die "codex-room-sync py_compile"

# 2. The load-bearing symlink.
[ "$(readlink "$HOME/.paseo/orchestration")" = "$REPO/runtime" ] \
  || die "~/.paseo/orchestration does not symlink to $REPO/runtime"

# 3. Every provider command in the live wiring table stays in orchestration/bin.
outside="$(jq -r '.agents.providers | to_entries[] | select(.value.command) | .value.command[0]' \
  "$HOME/.paseo/config.json" | grep -v "^$HOME/.paseo/orchestration/bin/")"
[ -z "$outside" ] || die "provider command outside orchestration/bin: $outside"

# 4. Codex runtime generation per role.
for role in supervisor lead peer peer-zen review; do
  if ! "$RT/bin/codex-room-sync" "$role" 2>/dev/null; then
    die "codex-room-sync $role"
    continue
  fi
  cfg="$HOME/.codex-runtime/$role/config.toml"
  grep -q '^developer_instructions = """' "$cfg" || die "$role: no developer_instructions"
  grep -q '^multi_agent = false' "$cfg" || die "$role: multi_agent not disabled"
  jq -e '[.models[].multi_agent_version] | all(. == null)' \
    "$HOME/.codex-runtime/$role/model-catalog.no-native-agents.json" >/dev/null \
    || die "$role: catalog still advertises native agents"
done
grep -q 'Room role: Peer' "$HOME/.codex-runtime/peer-zen/config.toml" \
  || die "peer-zen: inherited peer instructions missing"
[ ! -e "$HOME/.codex-runtime/review/skills" ] \
  || die "review seat must not link default skills"

# 5. Claude seat profiles seeded (created on first launch; check when present).
for role in lead peer supervisor; do
  p="$HOME/.claude/profiles/claude-$role"
  [ -d "$p" ] || continue
  [ "$(readlink "$p/settings.json")" = "$RT/profiles/settings.json" ] \
    || die "claude-$role: settings.json not linked to runtime profile settings"
  [ -L "$p/skills" ] || die "claude-$role: skills symlink missing"
done

if [ "$fail" -eq 0 ]; then
  echo SMOKE_OK
fi
exit "$fail"
