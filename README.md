# Paseo room setup (`~/.paseo/orchestration`)

One git checkout, living inside the Paseo daemon home, owns the whole
multi-agent room configuration: Claude role seats, Codex role seats, hooks,
protocol doctrine, and the reference copy of the daemon wiring table.
There are no symlink indirections and no installer — the checkout itself
is the live surface.

```text
~/.paseo/                       Paseo daemon home — delete it and the room
│                               (minus ~/.claude/profiles, see below) is gone
├── config.json                 daemon-owned wiring table: agents.providers
│                               command -> orchestration/bin/<launcher>
├── orchestration/              THIS git checkout (master)
│   ├── bin/                    launchers: claude-{lead,peer,supervisor},
│   │                           claude-profile, codex-room, codex-room-sync
│   ├── roles/                  Claude role prompts (lead|peer|supervisor.md)
│   ├── profiles/               settings.json shared by Claude seat profiles
│   ├── overlays/               Codex role overlays (<role>.config.toml)
│   ├── hooks/                  Claude seat hooks (role-gate, inject, telemetry)
│   ├── protocol/               room doctrine (workspace protocol, handoff, ...)
│   ├── paseo/config.json       reference copy of the wiring table
│   ├── PHILOSOPHY.md TARGET.md SUPERVISOR_NOTEBOOK.md
│   ├── telemetry/  attic/      operational data + old backups (gitignored)
│   └── tests/smoke.sh
├── codex-runtime/<role>/       generated CODEX_HOMEs (regenerated per launch)
└── agents/ projects/ schedules/ loops/ ...   daemon state
```

## Full footprint

Everything this setup touches, so removal is deterministic:

- `~/.paseo/orchestration/` and `~/.paseo/codex-runtime/` — this checkout
  and its generated Codex homes. Both vanish with `~/.paseo`.
- `~/.paseo/config.json` — daemon-owned; the provider table points into
  `orchestration/bin`. Reference copy: `paseo/config.json` here.
- `~/.paseo/claude-profiles/claude-{lead,peer,supervisor}/` — isolated Claude seat
  homes (sessions, seeded settings/skills symlinks, `.credentials.json`).
  Live seat homes; delete freely, reseeded on next launch.
- Read-only inputs, never written: `~/.codex/` (operator base config, auth,
  skills), `~/.claude/skills` (shared into seat profiles by symlink),
  `/opt/homebrew/etc/cliproxyapi.conf` (API keys, read at launch).

## Claude seats

`claude-profile <role>` (wrapped by `claude-lead|peer|supervisor`) runs each
seat in an isolated profile home via `CLAUDE_CONFIG_DIR` — the documented
mechanism for multiple profiles (code.claude.com/docs/en/settings). Seat env:
`CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` (durable findings belong in handbacks or
repo docs, not per-seat auto-memory) and `ROOM_ROLE=<role>` (consumed by the
hooks). First launch seeds the profile: settings.json -> `profiles/settings.json`
here, skills -> `~/.claude/skills`, `.credentials.json` from the shared macOS
Keychain entry, and a trust record for the launch directory. The role prompt
`roles/<role>.md` ships via `--append-system-prompt` and is re-injected on
SessionStart by `hooks/inject-profile.sh` (stream-json mode drops the flag).

If a seat reports "Not logged in": delete that profile's `.credentials.json`
and relaunch to re-seed, or run `/login` inside the profile.

## Codex seats

`codex-room <role>` regenerates `~/.paseo/codex-runtime/<role>/` on every
launch: operator base `~/.codex/config.toml` + overlay
`overlays/<role>.config.toml` -> merged `config.toml`, plus a model catalog
patched to disable Codex-native agents and floor reasoning at high. Roles:
`supervisor` (watcher), `lead` (unwired spare), `peer`, `peer-zen`
(Zen-direct Luna transport), `review` (OCR lane, no default skills).
Overlay room-directives: `room_instructions_from` (prompt inheritance),
`room_link_default_skills = false`.

Never edit a generated `config.toml` — change the overlay or the base and
relaunch (or run `bin/codex-room-sync <role>`).

The overlay/sync/launcher pattern follows hoangnb24/codex-room-setup;
deviations: no Paseo fork submodule (official Paseo.app), overlays live in
this checkout, extra roles `peer-zen`/`review`, and Claude seats are
first-class here.

## Verify

```bash
tests/smoke.sh    # prints SMOKE_OK
```
