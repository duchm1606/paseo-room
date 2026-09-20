#!/usr/bin/env bash
# Wiring + generation smoke test. No daemon calls, no model calls.
set -uo pipefail

fail=0
die() { printf 'FAIL: %s\n' "$*"; fail=1; }

ROOM="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 1. The room checkout lives inside the daemon home, as a git repository.
[ "$ROOM" = "$HOME/.paseo/orchestration" ] \
  || die "room checkout is at $ROOM, expected ~/.paseo/orchestration"
[ -d "$ROOM/.git" ] || die "room checkout is not a git repository"

# 2. Scripts parse.
bash -n "$ROOM/bin/claude-profile" "$ROOM/bin/claude-lead" "$ROOM/bin/claude-peer" \
  "$ROOM/bin/claude-supervisor" "$ROOM/bin/claude-seat-token" \
  "$HOME/.local/bin/codex-room" "$ROOM"/hooks/*.sh \
  || die "bash -n on launchers/hooks"
python3 -m py_compile "$HOME/.local/bin/codex-room-sync" || die "codex-room-sync py_compile"

# 3. Provider commands: claude seats launch from the room checkout, codex
#    seats from ~/.local/bin (codex-room lives with the Codex config).
outside="$(jq -r '.agents.providers | to_entries[] | select(.value.command) | .value.command[0]' \
  "$HOME/.paseo/config.json" \
  | grep -v -e "^$HOME/.paseo/orchestration/bin/" -e "^$HOME/.local/bin/codex-room$")"
[ -z "$outside" ] || die "unexpected provider command: $outside"

# 4. Codex role overlays present, runtime generation per role.
for role in supervisor lead peer peer-zen; do
  [ -f "$HOME/.codex/$role.config.toml" ] || { die "$role: overlay missing in ~/.codex"; continue; }
  if ! "$HOME/.local/bin/codex-room-sync" "$role" 2>/dev/null; then
    die "codex-room-sync $role"
    continue
  fi
  rt="$HOME/.codex-runtime/$role"
  grep -q '^developer_instructions = """' "$rt/config.toml" || die "$role: no developer_instructions"
  grep -q '^multi_agent = false' "$rt/config.toml" || die "$role: multi_agent not disabled"
  jq -e '[.models[].multi_agent_version] | all(. == null)' \
    "$rt/model-catalog.no-native-agents.json" >/dev/null \
    || die "$role: catalog still advertises native agents"
done
grep -q 'Room role: Peer' "$HOME/.codex-runtime/peer-zen/config.toml" \
  || die "peer-zen: inherited peer instructions missing"
# Codex itself creates a real skills/.system dir in every CODEX_HOME; the review
# seat must merely never link the operator's default skills/plugins.
[ ! -L "$HOME/.codex-runtime/review/skills" ] \
  || die "review seat must not link default skills"
[ ! -L "$HOME/.codex-runtime/review/plugins" ] \
  || die "review seat must not link default plugins"

# 5. Claude seat profiles seeded (created on first launch; check when present).
[ -f "$HOME/.claude/profiles/settings.json" ] || die "shared seat settings missing in ~/.claude/profiles"
for role in lead peer supervisor; do
  p="$HOME/.claude/profiles/claude-$role"
  [ -d "$p" ] || continue
  [ "$(readlink "$p/settings.json")" = "$HOME/.claude/profiles/settings.json" ] \
    || die "claude-$role: settings.json not linked to shared seat settings"
  [ -L "$p/skills" ] || die "claude-$role: skills symlink missing"
done

# 6. Seat credential preflight. No model call — this only checks that the
#    launcher can RESOLVE a token, which is the exact failure that used to
#    surface as a dead seat minutes after a Lead was briefed.
tok="${CLAUDE_CODE_OAUTH_TOKEN:-}"
if [ -z "$tok" ] && [ -r "$HOME/.zshrc" ]; then
  l="$(grep -E '^[[:space:]]*export[[:space:]]+CLAUDE_CODE_OAUTH_TOKEN=' "$HOME/.zshrc" | tail -1)"
  tok="${l#*=}"; tok="${tok%\"}"; tok="${tok#\"}"; tok="${tok%\'}"; tok="${tok#\'}"
fi
case "$tok" in
  sk-ant-oat*) ;;
  "") die "no CLAUDE_CODE_OAUTH_TOKEN resolvable from the environment or ~/.zshrc; every claude seat will refuse to start" ;;
  *)  die "CLAUDE_CODE_OAUTH_TOKEN does not look like a setup-token (expected sk-ant-oat...)" ;;
esac
for v in ANTHROPIC_AUTH_TOKEN ANTHROPIC_API_KEY; do
  [ -z "${!v:-}" ] || die "$v is set and outranks CLAUDE_CODE_OAUTH_TOKEN; seats would authenticate with it instead"
done

if [ "$fail" -eq 0 ]; then
  echo SMOKE_OK
fi
exit "$fail"
