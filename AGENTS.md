# Agent rules for this repository

This checkout is LIVE: the daemon launches Claude seats from `bin/` and the
hooks fire from `hooks/`, so an edit here changes the next seat launch
immediately. There is no build step between you and production.

- Edit on a topic branch and merge to `master`; never leave `master` broken.
  Run `tests/smoke.sh` before merging anything under `bin/` or `hooks/`.
- Role prompts (`roles/*.md`, and `developer_instructions` in
  `~/.codex/<role>.config.toml`) are owner-approved text. Restructure around
  them freely; do not reword them without an explicit owner request.
- Tool config lives in tool homes, not here: Codex role overlays in
  `~/.codex/<role>.config.toml`, codex-room scripts in `~/.local/bin`,
  shared Claude seat settings in `~/.claude/profiles/settings.json`. This
  repo keeps only the room coordination layer (launchers, hooks, prompts,
  doctrine).
- Never edit generated state: `~/.codex-runtime/<role>/` is rebuilt on every
  launch; `~/.claude/profiles/claude-<role>/` is seat-live state (only its
  seeded symlinks are managed, by `bin/claude-profile`).
- `~/.paseo/config.json` is daemon-owned. `paseo/config.json` here is the
  reviewed reference copy; when you change the provider table, change both
  and run `paseo reload`.
- `telemetry/*.jsonl` and `attic/` accrue during operation and are
  gitignored; `SUPERVISOR_NOTEBOOK.md` is versioned — append deliberately,
  never rewrite its history casually.
- Everything written to disk is in English.
