#!/usr/bin/env bash
# Wiring + generation smoke test. No daemon calls, no model calls.
set -uo pipefail

fail=0
die() { printf 'FAIL: %s\n' "$*"; fail=1; }

ROOM="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mode() { stat -c '%a' "$1" 2>/dev/null || stat -f '%OLp' "$1"; }  # GNU, then BSD
CODEX_ROOM="$HOME/.local/bin/codex-room"

# 1. The room checkout lives inside the daemon home, as a git repository.
[ "$ROOM" = "$HOME/.paseo/orchestration" ] \
  || die "room checkout is at $ROOM, expected ~/.paseo/orchestration"
[ -d "$ROOM/.git" ] || die "room checkout is not a git repository"

# 2. Scripts parse.
bash -n "$ROOM/bin/claude-profile" "$ROOM/bin/claude-lead" "$ROOM/bin/claude-peer" \
  "$ROOM/bin/claude-supervisor" "$ROOM/bin/claude-seat-token" \
  "$ROOM/bin/room-install" "$ROOM/bin/room-sync" \
  "$ROOM/codex/bin/codex-room" "$ROOM"/hooks/*.sh \
  || die "bash -n on launchers/hooks"
python3 -c 'import ast,sys; ast.parse(open(sys.argv[1]).read())' "$ROOM/codex/bin/codex-room-sync" \
  || die "codex-room-sync does not parse"
for f in "$ROOM"/hosts/*.json "$ROOM/claude/seat-settings.json"; do
  jq -e . "$f" >/dev/null || die "$f is not valid JSON"
done

# 3. Provider commands: claude seats launch from the room checkout; the seats
#    built on another tool launch from ~/.local/bin, where that tool's own
#    config lives — codex-room for Codex, agy-acp for the Gemini ACP bridge.
outside="$(jq -r '.agents.providers | to_entries[] | select(.value.command) | .value.command[0]' \
  "$HOME/.paseo/config.json" \
  | grep -v -e "^$HOME/.paseo/orchestration/bin/" \
            -e "^$HOME/.local/bin/codex-room$" \
            -e "^$HOME/.local/bin/agy-acp$")"
[ -z "$outside" ] || die "unexpected provider command: $outside"

# 4. Codex roles the provider table actually launches: installed from this
#    checkout, overlay present, runtime generation works.
codex_roles="$(jq -r --arg c "$CODEX_ROOM" \
  '.agents.providers[] | select(.command[0]? == $c) | .command[1]' \
  "$HOME/.paseo/config.json" | sort -u)"
if [ -n "$codex_roles" ]; then
  for f in codex-room codex-room-sync; do
    [ "$(readlink "$HOME/.local/bin/$f")" = "$ROOM/codex/bin/$f" ] \
      || die "~/.local/bin/$f is not linked to this checkout (run bin/room-install)"
  done
fi
for role in $codex_roles; do
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

# 4b. The live provider table is the rendered host template: any drift means a
#     hand edit that the next room-install would silently revert.
host="$(cat "$HOME/.paseo/room-host" 2>/dev/null || true)"
if [ -n "$host" ]; then
  want="$(jq -S --arg h "$HOME" 'walk(if type=="string" then gsub("@HOME@"; $h) else . end)
    | {pluginsEnabled, plugins, providers: .agents.providers}' "$ROOM/hosts/$host.json")"
  have="$(jq -S '{pluginsEnabled, plugins, providers: .agents.providers}' "$HOME/.paseo/config.json")"
  [ "$want" = "$have" ] || die "~/.paseo/config.json drifted from hosts/$host.json (run bin/room-install, or move the edit into the repo)"
fi

# 4c. Room skills are well-formed: one SKILL.md per directory, named after it.
for d in "$ROOM"/skills/*/; do
  n="$(basename "$d")"
  grep -q "^name: $n\$" "$d/SKILL.md" 2>/dev/null || die "skills/$n: SKILL.md missing or its name is not $n"
done

# 5. Claude seat profiles seeded (created on first launch; check when present).
#    Each seat owns a REAL settings.json holding its own token. This check
#    asserted the opposite until 2026-09-21 — a symlink to the shared file —
#    which is the shape bin/claude-profile now exits 3 on, because N seats
#    sharing one credential lineage is the outage that design closed.
#    ~/.claude/profiles/settings.json survives only as the seed a new seat is
#    copied from, and it carries a live token, so it is held at mode 600 too.
tpl="$HOME/.claude/profiles/settings.json"
if [ ! -f "$tpl" ] || [ -L "$tpl" ]; then
  die "seat settings template missing (or a symlink) at $tpl"
else
  m="$(mode "$tpl")"
  [ "$m" = "600" ] || die "$tpl is mode $m, expected 600 — it holds a one-year token"
fi
for role in lead peer supervisor; do
  p="$HOME/.claude/profiles/claude-$role"
  [ -d "$p" ] || continue
  if [ -L "$p/settings.json" ] || [ ! -f "$p/settings.json" ]; then
    die "claude-$role: settings.json must be a real file, not a symlink (claude-profile refuses to start otherwise)"
  else
    m="$(mode "$p/settings.json")"
    [ "$m" = "600" ] || die "claude-$role: settings.json is mode $m, expected 600"
  fi
  [ "$(readlink "$p/skills")" = "$ROOM/skills" ] || die "claude-$role: skills must link to $ROOM/skills"
done
# The key registry claude-seat-token writes, when the operator has one.
reg="$HOME/.claude/profiles/tokens.json"
if [ -f "$reg" ]; then
  m="$(mode "$reg")"
  [ "$m" = "600" ] || die "$reg is mode $m, expected 600 — it holds every seat token"
fi

# 6. Seat credential preflight. No model call — this only checks that every
#    seat can RESOLVE a token, which is the exact failure that used to surface
#    as a dead seat minutes after a Lead was briefed.
#
#    Read it where the launcher reads it: each seat's own settings.json. This
#    grepped ~/.zshrc until 2026-09-21, one rollout behind the launcher, so a
#    seat could sit tokenless and still pass. Rotate with `seat-token set`.
for role in lead peer supervisor; do
  s="$HOME/.claude/profiles/claude-$role/settings.json"
  [ -f "$s" ] || continue   # unseeded seat: section 5 already spoke
  tok="$(jq -r '.env.CLAUDE_CODE_OAUTH_TOKEN // ""' "$s" 2>/dev/null || echo "")"
  case "$tok" in
    sk-ant-oat*) ;;
    "") die "claude-$role: no env.CLAUDE_CODE_OAUTH_TOKEN in its settings.json; the seat will refuse to start (mint one with \`claude setup-token\`, then: seat-token set <key> --seat $role)" ;;
    *)  die "claude-$role: env.CLAUDE_CODE_OAUTH_TOKEN is not a setup-token (expected sk-ant-oat...)" ;;
  esac
done
case "$(jq -r '.env.CLAUDE_CODE_OAUTH_TOKEN // ""' "$tpl" 2>/dev/null)" in
  sk-ant-oat*) ;;
  *) die "the seat template carries no usable token; the next seat seeded from it would start dead" ;;
esac
for v in ANTHROPIC_AUTH_TOKEN ANTHROPIC_API_KEY; do
  [ -z "${!v:-}" ] || die "$v is set and outranks CLAUDE_CODE_OAUTH_TOKEN; seats would authenticate with it instead"
done

if [ "$fail" -eq 0 ]; then
  echo SMOKE_OK
fi
exit "$fail"
