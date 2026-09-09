# Paseo room setup (`~/.paseo/orchestration`)

This git checkout owns the room coordination layer: Claude seat launchers,
hooks, role prompts, protocol doctrine, and the reference copy of the daemon
wiring table. Tool configuration lives in each tool's own home, following
the codex-room pattern (see `~/Downloads/Orchestration Collection/`
codex-room-paseo-clean-install-guide.md).

```text
~/.paseo/
├── config.json                daemon-owned wiring table: agents.providers
│                              claude seats -> orchestration/bin/<launcher>
│                              codex seats  -> ~/.local/bin/codex-room <role>
├── orchestration/             THIS git checkout (master)
│   ├── bin/                   claude-{lead,peer,supervisor}, claude-profile
│   ├── roles/                 Claude role prompts (lead|peer|supervisor.md)
│   ├── hooks/                 Claude seat hooks (role-gate, inject, telemetry)
│   ├── protocol/              room doctrine (workspace protocol, handoff, ...)
│   ├── paseo/config.json      reference copy of the wiring table
│   ├── PHILOSOPHY.md TARGET.md SUPERVISOR_NOTEBOOK.md
│   ├── telemetry/  attic/     operational data + old backups (gitignored)
│   └── tests/smoke.sh
└── agents/ projects/ ...      daemon state

~/.claude/                     Claude Code home (operator)
├── profiles/settings.json     shared seat settings (hooks, plugin kill-switch)
└── profiles/claude-<role>/    isolated seat homes (CLAUDE_CONFIG_DIR):
                               settings.json + skills seeded as symlinks,
                               .claude.json/.credentials.json seeded on launch

~/.codex/                      Codex home (operator base, shared by all roles)
├── config.toml                base config
├── <role>.config.toml         role overlays: supervisor|lead|peer|peer-zen|review
└── auth/skills/plugins/...    symlinked into each role runtime

~/.codex-runtime/<role>/       generated CODEX_HOMEs (regenerated per launch)

~/.local/bin/                  codex-room, codex-room-sync (real scripts,
                               per the codex-room install guide)
```

## Claude seats

`claude-profile <role>` (wrapped by `claude-lead|peer|supervisor`) runs each
seat in an isolated profile home `~/.claude/profiles/claude-<role>` via
`CLAUDE_CONFIG_DIR` — the documented mechanism for multiple profiles
(code.claude.com/docs/en/settings). Seat env: `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`
(durable findings belong in handbacks or repo docs, not per-seat auto-memory)
and `ROOM_ROLE=<role>` (consumed by the hooks). First launch seeds the
profile: settings.json -> `~/.claude/profiles/settings.json`, skills ->
`~/.claude/skills`, `.credentials.json` from the shared macOS Keychain entry,
and a trust record for the launch directory. The role prompt `roles/<role>.md`
ships via `--append-system-prompt` and is re-injected on SessionStart by
`hooks/inject-profile.sh` (stream-json mode drops the flag).

If a seat reports "Not logged in": delete that profile's `.credentials.json`
and relaunch to re-seed, or run `/login` inside the profile.

## Codex seats

`codex-room <role>` regenerates `~/.codex-runtime/<role>/` on every launch:
base `~/.codex/config.toml` + overlay `~/.codex/<role>.config.toml` ->
merged `config.toml`, plus a model catalog patched to disable Codex-native
agents and floor reasoning at high. Roles: `supervisor` (watcher), `lead`
(unwired spare), `peer`, `peer-zen` (Zen-direct Luna transport), `review`
(OCR lane, no default skills). Overlay room-directives:
`room_instructions_from` (prompt inheritance), `room_link_default_skills = false`.

Never edit a generated `config.toml` — change the base or the overlay and
relaunch (or run `codex-room-sync <role>`).

## Verify

```bash
tests/smoke.sh    # prints SMOKE_OK
```
