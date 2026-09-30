# Agent rules for this repository

This checkout is LIVE: the daemon launches Claude seats from `bin/` and the
hooks fire from `hooks/`, so an edit here changes the next seat launch
immediately. There is no build step between you and production.

- Edit on a topic branch and merge to `master`; never leave `master` broken.
  Run `tests/smoke.sh` before merging anything under `bin/` or `hooks/`.
- Role prompts (`roles/*.md`, and `developer_instructions` in
  `~/.codex/<role>.config.toml`) are owner-approved text. Restructure around
  them freely; do not reword them without an explicit owner request.
- Tools still read their own homes, but what the room manages there is
  sourced from this repo and installed by `bin/room-install <host>`:
  the Paseo provider table (`hosts/<host>.json`), seat settings
  (`claude/seat-settings.json`), the seat skill set (`skills/`), and the
  codex-room scripts plus the peer overlay (`codex/`). Edit the repo copy,
  never the installed one. Everything else in a tool home (the Codex base
  `~/.codex/config.toml`, unmanaged overlays, the operator's own
  `~/.claude/skills`) stays host-local.
- No secret is ever committed. Seat tokens live only in each seat's
  `settings.json` (mode 600); the CLIProxy key is read at launch from the
  proxy config or `CLIPROXY_API_KEY`.
- Never edit generated state: `~/.codex-runtime/<role>/` is rebuilt on every
  launch; `~/.claude/profiles/claude-<role>/` is seat-live state (only its
  seeded symlinks are managed, by `bin/claude-profile`).
- `~/.paseo/config.json` is daemon-owned except `daemon.mcp`, `pluginsEnabled`,
  `plugins` and `agents.providers`, which room-install renders from
  `hosts/<host>.json` (`@HOME@` becomes the host's home). Change the host
  file, run `bin/room-install`, then restart the daemon when no seat is
  mid-task. `tests/smoke.sh` fails on drift between the two.
- `telemetry/*.jsonl` and `attic/` accrue during operation and are
  gitignored; `SUPERVISOR_NOTEBOOK.md` is versioned — append deliberately,
  never rewrite its history casually.
- Everything written to disk is in English.
