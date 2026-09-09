# Agent rules for this repository

This checkout IS the live surface: `~/.paseo/orchestration` is the repo
itself, so an edit here changes the next seat launch (and fired hooks)
immediately. There is no build step between you and production.

- Edit on a topic branch and merge to `master`; never leave `master` broken.
  Run `tests/smoke.sh` before merging anything under `bin/`, `hooks/`,
  `overlays/`, or `profiles/`.
- Role prompts (`roles/*.md`, overlay `developer_instructions`) are
  owner-approved text. Restructure around them freely; do not reword them
  without an explicit owner request.
- Never edit generated state: `~/.paseo/codex-runtime/<role>/` is rebuilt on
  every launch from `overlays/` + `~/.codex/config.toml`;
  `~/.claude/profiles/claude-<role>/` is seat-live state (only its seeded
  symlinks belong to this repo).
- `~/.paseo/config.json` is daemon-owned. `paseo/config.json` here is the
  reviewed reference copy; when you change the provider table, change both
  and run `paseo reload`.
- Keep every new path reference on `~/.paseo/...`; the room's footprint
  outside it is exactly `~/.claude/profiles/claude-*` (see README) — do not
  grow it.
- `telemetry/*.jsonl` and `attic/` accrue during operation and are
  gitignored; `SUPERVISOR_NOTEBOOK.md` is versioned — append deliberately,
  never rewrite its history casually.
- Everything written to disk is in English.
