# Lead operations — spawning and driving peer sessions

The orchestration interface is the `paseo` CLI, on PATH
(`~/.local/bin/paseo`, symlinked from the app bundle at
`/Applications/Paseo.app/Contents/Resources/bin/paseo` — never
npm-install @getpaseo/cli alongside the desktop app). Call it plainly
as `paseo`. Every command returns parseable output; add `--json` where
you need fields.

## Delegation loop (one case, one Engineer)

```bash
# 1. Spawn — one `peer` provider; the DISPOSITION goes in the prompt
#    (Engineer/Architect/Reviewer/Scout/auditor/advisor + mutation boundary).
#    Model per the routing law (Opus = bounded, Fable = harder
#    vertical/lifecycle-sensitive work).
paseo run -d --provider peer --model claude-opus-5 \
  --title "peer/eng: <case-slug>" "<context pack as a direct work request>" --json
#    → parse .agentId

# 2. Wait for the deliverable — event-style, never poll in a loop
paseo wait <agentId> --timeout 900

# 3. Read the handback
paseo logs <agentId>

# 4. Follow up in the same session (cache stays hot) …
paseo send <agentId> "<follow-up>"
paseo wait <agentId> --timeout 900

# 5. … or retire the session when the case closes
paseo archive <agentId>
```

Reviewers, Architects, and Scouts spawn the same way — same `peer`
provider, different disposition in the brief. Read-only is enforced by
the disposition and mutation boundary you state in the brief (the profile
backs it up); never grant a read-only disposition work that requires
edits, and always name the mutation boundary explicitly.

## Discipline

- **One Engineer per writable scope.** Never run two Engineers whose write
  scopes can touch the same files. For parallel work, use
  `--new-workspace worktree` so each owner gets an isolated checkout.
- **Context packs follow `context-pack.md`** — goal, verified facts, real
  constraints, acceptance contract, granted permissions. Direct work-request
  voice. Never mention paseo, sessions, or orchestration mechanics to peers.
- **No polling.** `wait` blocks until idle — that is your completion signal.
  If `wait` times out, `inspect` once, read `logs` once, decide: extend the
  wait, send a follow-up, or rule the case blocked. Do not loop status
  checks.
- **Crash recovery.** A daemon restart kills in-flight background `wait`s
  ("Background command … was stopped") but peer sessions persist. Never
  assume the peer died: `logs` the session to see where it stopped, `send`
  a resume prompt if its turn was cut mid-work, then re-arm one `wait`.
  On any fresh wake, reconcile your in-flight cases before starting new
  ones.
- **Council seats** are separate `run` invocations with a neutral brief and
  an explicit method each — never share one session across seats, never let
  a seat read another seat's output.
- **Rulings are in-thread.** Before a case proceeds past a
  REOPEN_REQUEST, DEPENDENCY_REQUEST, BLOCKED, or an overridden
  dissent, state the concrete ruling and its reasons in the
  conversation (request gist → ruling → reasons → dissent kept
  yes/no). Session logs are the archive; no record files.
- **Session economics.** Prefer follow-ups into a live session (hot cache)
  while the mental model is valuable; spawn fresh with a tighter context
  pack when the session has compacted repeatedly or drifted. `logs` before
  you decide.
- **Reconcile** after every 3–4 closed cases: re-check priorities against
  dependency and leverage, absorb superseded issues (the repo protocol names
  the tracker, if any), archive idle sessions you own.

## Closing report — layered status

One PASS never covers a layer that was not tested. Report each layer
with its own verdict (`PASS` / `BLOCKED` / `NOT TESTED` / `UNKNOWN`)
and stop at the layer actually proven.

```text
SOURCE     snapshot · diff/review · checks · verdict
ARTIFACT   build/run · identity/checksum · inspection · verdict
INSTALLED  candidate provenance · configuration preserved · verdict
LIVE       daemon/API/UI · relevant journey · logs · verdict
RESIDUAL   unknown · blocker · human decision · next safe action
```

Layers the task never reached are listed as `NOT TESTED`, not
omitted. A BLOCKED activation does not erase a source PASS; a source
PASS does not swallow a live blocker.
