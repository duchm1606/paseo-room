# Paseo room setup (`~/.paseo/orchestration`)

This git checkout owns the room coordination layer — Claude seat launchers,
hooks, role prompts, protocol doctrine — plus the sources for what the room
manages inside other tools' homes. `bin/room-install` applies it to the
machine it runs on; GitHub carries it between machines. Every host gets the
same configuration: there is no per-host file.

```text
~/.paseo/orchestration/        THIS checkout (master), same path on every host
├── bin/                       claude-{lead,peer,supervisor}, claude-profile,
│                              claude-seat-token, room-install, room-sync
├── roles/                     role law: lead, peer (Claude and Codex seats),
│                              supervisor, watcher
├── hooks/                     Claude seat hooks (role-gate, inject, telemetry)
├── protocol/                  room doctrine (workspace protocol, handoff, ...)
├── skills/                    the seat skill set (seats see only these)
├── room.json                  provider table, the same on every host
├── claude/seat-settings.json  seat settings minus the token
├── codex/                     codex-room, codex-room-sync, peer and
│                              supervisor overlays
├── watcher/                   Watcher tool gate (agy PreToolUse hook)
├── PHILOSOPHY.md TARGET.md SUPERVISOR_NOTEBOOK.md
├── telemetry/  attic/         operational data + old backups (gitignored)
└── tests/smoke.sh

Installed by room-install (symlink or rendered copy):
~/.paseo/config.json           daemon.mcp, pluginsEnabled, plugins, agents.providers
                               <- room.json with @HOME@ expanded
~/.claude/profiles/settings.json            seat template   } managed keys from
~/.claude/profiles/claude-<role>/settings.json  per seat    } claude/, token kept
~/.claude/profiles/claude-<role>/skills  -> skills/
~/.local/bin/codex-room{,-sync}          -> codex/bin/
~/.codex/peer.{config.toml,catalog-extra.json} -> codex/
~/.codex/supervisor.config.toml          -> codex/
~/.paseo/watcher/AGENTS.md               -> roles/watcher.md
~/.paseo/watcher/.agents/{hooks.json,watcher-gate.sh} -> watcher/
```

Host-local and never synced: `~/.codex/config.toml` (Codex base, provider
endpoints), other `~/.codex/<role>.config.toml` overlays, the operator's own
`~/.claude/skills`, daemon keys in `~/.paseo/config.json` (listen, hostnames,
relay, ...), and every secret.

## Sync between hosts

```bash
# on the machine where you changed something
cd ~/.paseo/orchestration && tests/smoke.sh && git commit -am '...' && git push

# on every other host
~/.paseo/orchestration/bin/room-sync     # pull --ff-only + room-install
```

Then restart the daemon when no seat is mid-task (a restart kills running
agents): the Paseo desktop app on macOS, `sudo systemctl restart
paseo-daemon` on duckling-oci.

## First install on a new host

```bash
git clone https://github.com/duchm1606/paseo-room.git ~/.paseo/orchestration
~/.paseo/orchestration/bin/room-install
```

Prerequisites: `jq`, `claude`, `codex`, `python3` and a running CLIProxyAPI whose key is in
`CLIPROXY_API_KEY` or the proxy config. The daemon must have started once so
`~/.paseo/config.json` exists. A seat without a token is seeded from the seat
template, else from the operator's `~/.claude/settings.json`; otherwise mint
one with `claude setup-token` and set it with `claude-seat-token`.

## Claude seats

`claude-profile <role>` (wrapped by `claude-lead|peer|supervisor`) runs each
seat in an isolated profile home `~/.claude/profiles/claude-<role>` via
`CLAUDE_CONFIG_DIR`. Seat env: `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` (durable
findings belong in handbacks or repo docs, not per-seat auto-memory) and
`ROOM_ROLE=<role>` (consumed by the hooks). Each seat authenticates with its
own `CLAUDE_CODE_OAUTH_TOKEN` in its own `settings.json`; the launcher refuses
to start without one. The role prompt `roles/<role>.md` ships via
`--append-system-prompt` and is re-injected on SessionStart by
`hooks/inject-profile.sh` (stream-json mode drops the flag).

Seats see only `skills/` plus Claude Code built-ins and repo project skills;
`hooks/role-gate.sh` then narrows that to a per-role allow-list.

## Codex seats

`codex-room <role>` regenerates `~/.codex-runtime/<role>/` on every launch:
base `~/.codex/config.toml` + overlay `~/.codex/<role>.config.toml` ->
merged `config.toml`, plus a model catalog patched to disable Codex-native
agents and floor reasoning at high. Two roles are wired to a provider:
`peer` (`codex-peer`) and `supervisor` (`codex-supervisor`). Their overlays
are versioned here and take their instructions from `roles/peer.md` and
`roles/supervisor.md` (`room_instructions_file`), the same law the Claude
seats run. A role's Codex seat sees the operator's `~/.codex/skills` plus
the room skills `codex-room-sync` lists for it (`ROOM_SKILLS`).

Never edit a generated `config.toml` — change the base or the overlay and
relaunch (or run `codex-room-sync <role>`).

## Watcher seat

`watcher` is a Gemini seat on the agy-acp bridge that the
Supervisor starts per supervised workspace and feeds PATROL letters; it
judges Lead and Peer activity against the patterns in `roles/watcher.md`
and answers only the Supervisor. ACP seats cannot take
`--append-system-prompt`, so the provider passes
`--add-dir ~/.paseo/watcher` to agy, which loads that directory's
`AGENTS.md` as rules and `.agents/hooks.json` as a PreToolUse gate. The
gate denies every tool except `paseo ls|logs|inspect`. The directory
must stay outside any git repository (agy would also load the repo's
`AGENTS.md`), and the seat must be started with it as working directory.

## Gemini seats (agy)

`gemini`, `gemini-peer`, `gemini-lead`, `gemini-supervisor` and `watcher`
run on the agy-acp ACP bridge. A host needs, outside this repo:

```bash
curl -fsSL https://antigravity.google/cli/install.sh | bash   # ~/.local/bin/agy
# agy-acp: the locally patched tree (~/.local/src/agy-acp, see LOCAL-PATCHES.md)
cargo build --release && install -m 755 target/release/agy-acp ~/.local/bin/
# Google sign-in: run `agy` once interactively (SSH prints a login URL), or
# copy ~/.gemini/antigravity-cli/antigravity-oauth-token (mode 600) from a
# signed-in host.
```

## Host notes

`room.json` is the same everywhere. What differs between machines is what
they have, and a seat a machine cannot serve fails at launch with the reason.

- Mac: CLIProxyAPI from Homebrew (`/opt/homebrew/etc/cliproxyapi.conf`).
  Its Codex account (anbinh250202) serves gpt-6.1-sol and gpt-6-astra
  (probed 2026-11-03: low to max accepted, ultra rejected). No `pi`, no
  `~/.paseo/glm.key`: `glm` and `glm-researcher` do not start here.
- duckling-oci: CLIProxyAPI key in the daemon environment (systemd
  EnvironmentFile `~/.config/cliproxy.env`). Its Codex OAuth account
  (nguyenanhem91, moved from the Mac 2026-10-01) serves deepseek-v4.1-flash
  and gpt-6.1-sol; the other `codex-peer` models and the `codex-supervisor`
  model are listed but not served unless that account gains them. agy
  1.2.14 linux_arm64 from the official installer, agy-acp built on the host
  from `~/.local/src/agy-acp`, Google sign-in copied from the Mac token
  file; the paseo CLI is in `~/.npm-global/bin`. `~/.paseo/glm.key` and
  `~/.pi/agent/models.json` are here, so the GLM seats run here.

## Verify

```bash
tests/smoke.sh    # prints SMOKE_OK
```
