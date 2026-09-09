# airoom — Paseo room setup (canonical checkout)

One repository owns the whole multi-agent room configuration: Claude role
seats, Codex role seats, hooks, protocol doctrine, and the Paseo wiring
table. Everything the daemon touches goes through one symlink.

```text
~/.config/airoom/            <- CANONICAL checkout (master); the only place
│                               edits happen (topic branch -> merge)
├── runtime/                 <- the live surface
│   ├── bin/                    launchers: claude-{lead,peer,supervisor},
│   │                           claude-profile, codex-room, codex-room-sync
│   ├── roles/                  Claude role prompts (lead|peer|supervisor.md)
│   ├── profiles/               settings.json shared by Claude seat profiles
│   ├── overlays/               Codex role overlays (<role>.config.toml)
│   ├── hooks/                  Claude seat hooks (role-gate, inject, telemetry)
│   ├── protocol/               room doctrine (workspace protocol, handoff, ...)
│   ├── paseo/config.json       reference copy of the daemon wiring table
│   ├── telemetry/              seat telemetry (gitignored)
│   ├── PHILOSOPHY.md TARGET.md
│   └── SUPERVISOR_NOTEBOOK.md -> ../memory/SUPERVISOR_NOTEBOOK.md
├── memory/                  durable cross-workspace learning record
├── skills/                  reserved for seat-only skills (none yet)
└── tests/smoke.sh           wiring + generation smoke test

~/.paseo/                    <- DAEMON HOME (Paseo manages it)
├── config.json                 wiring table only: agents.providers
│                               (command -> orchestration/bin/<launcher>)
├── projects/ agents/ schedules/ loops/
└── orchestration -> ~/.config/airoom/runtime   (the one load-bearing symlink)
```

All prompts, hooks, and provider commands address paths under
`~/.paseo/orchestration/...`, so the checkout can move without touching any
prompt — only the symlink changes.

## Claude seats

`claude-profile <role>` (wrapped by `claude-lead|peer|supervisor`) runs each
seat in an isolated profile home:

```text
~/.claude/profiles/claude-<role>/     (CLAUDE_CONFIG_DIR)
├── settings.json -> runtime/profiles/settings.json
├── skills        -> ~/.claude/skills
└── .claude.json                      seeded on first launch
```

Seat env: `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` (no per-seat auto-memory;
durable findings go in handbacks or repo docs) and `ROOM_ROLE=<role>`
(consumed by the hooks). The role prompt `runtime/roles/<role>.md` is applied
via `--append-system-prompt` and re-injected on SessionStart by
`hooks/inject-profile.sh`. OAuth comes from the shared macOS Keychain.

## Codex seats

`codex-room <role>` regenerates `~/.codex-runtime/<role>/` on every launch via
`codex-room-sync`: operator base `~/.codex/config.toml` + role overlay
`runtime/overlays/<role>.config.toml` -> merged `config.toml`, plus a model
catalog patched to disable Codex-native agents and floor reasoning at high.
Roles: `supervisor` (watcher), `lead` (unwired spare), `peer`, `peer-zen`
(Zen-direct Luna transport), `review` (OCR lane, no default skills).

Never edit `~/.codex-runtime/<role>/config.toml` — change the overlay or the
base and relaunch (or run `runtime/bin/codex-room-sync <role>`).

## Relation to hoangnb24/codex-room-setup

The Codex overlay/sync/launcher pattern follows that repo. Deliberate
deviations: no Paseo fork submodule (this machine runs the official
Paseo.app), overlays live in this repo instead of `~/.config/codex-room`,
extra roles `peer-zen` and `review` exist for the CLIProxyAPI luna bug and
the OCR review lane, and Claude seats are first-class here.

## Verify

```bash
tests/smoke.sh    # prints SMOKE_OK
```
