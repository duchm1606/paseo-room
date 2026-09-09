# Agent rules for this repository

This checkout is LIVE: `~/.paseo/orchestration` symlinks into `runtime/`, so
an edit here changes the next seat launch (and fired hooks) immediately.
There is no build step between you and production.

- Edit on a topic branch and merge to `master`; never leave `master` broken.
  Run `tests/smoke.sh` before merging anything that touches `runtime/`.
- Role prompts (`runtime/roles/*.md`, overlay `developer_instructions`) are
  owner-approved text. Restructure around them freely; do not reword them
  without an explicit owner request.
- Never edit generated state: `~/.codex-runtime/<role>/` is regenerated on
  every launch from `runtime/overlays/` + `~/.codex/config.toml`;
  `~/.claude/profiles/claude-<role>/` is seat-live state (only its seeded
  symlinks belong to this repo).
- `~/.paseo/config.json` is daemon-owned. `runtime/paseo/config.json` is the
  reviewed reference copy; when you change the provider table, change both
  and note that the daemon needs a reload/restart.
- Paths in prompts, hooks, and the wiring table deliberately go through
  `~/.paseo/orchestration/...`. Keep new references on that path so the
  checkout stays relocatable.
- `runtime/telemetry/*.jsonl` and `memory/` accrue during operation; commit
  `memory/` deliberately, never rewrite its history casually.
- Everything written to disk is in English.
