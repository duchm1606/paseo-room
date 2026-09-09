# Install / redeploy

Prerequisites: Paseo.app, Claude Code (authenticated), Codex CLI with an
operator `~/.codex/` (config.toml, AGENTS.md, hooks.json, skills/, plugins/,
model-instructions.md), CLIProxyAPI at `/opt/homebrew/etc/cliproxyapi.conf`,
`jq`, Python 3.11+.

```bash
git clone <remote> ~/.config/airoom     # or move an existing checkout here

# 1. The one load-bearing symlink
mv ~/.paseo/orchestration ~/.paseo/orchestration.pre-airoom   # if present
ln -s ~/.config/airoom/runtime ~/.paseo/orchestration

# 2. Convenience CLI links (optional; the daemon does not need them)
ln -sf ~/.config/airoom/runtime/bin/codex-room      ~/.local/bin/codex-room
ln -sf ~/.config/airoom/runtime/bin/codex-room-sync ~/.local/bin/codex-room-sync

# 3. Daemon wiring table
#    Merge runtime/paseo/config.json into ~/.paseo/config.json (agents.providers
#    commands must point at ~/.paseo/orchestration/bin/<launcher>), then restart
#    or reload the Paseo daemon so it re-reads provider commands.

# 4. Verify
~/.config/airoom/tests/smoke.sh
```

Claude seat profiles (`~/.claude/profiles/claude-<role>`) and Codex role
runtimes (`~/.codex-runtime/<role>`) are seeded/regenerated automatically on
first seat launch; nothing to install there.

Claude seat auth: the launcher seeds each profile's `.credentials.json` once
from the shared macOS Keychain entry (`Claude Code-credentials`). If a seat
reports "Not logged in", delete that profile's `.credentials.json` and
relaunch to re-seed, or run `/login` inside the profile.

Upgrade path: pull the checkout; the symlink makes it live immediately for
new seat launches. Only `~/.paseo/config.json` changes (provider table)
need a daemon reload/restart.
