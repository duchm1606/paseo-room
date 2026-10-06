#!/usr/bin/env bash
# notify-on-stop.sh: Claude Code Stop hook for Lead seats.
#
# Paseo tells an agent that a turn finished only if that agent started the
# turn (one notification per prompt, to the caller). A Lead turn started by
# a Peer handback (or by a background-task notification) therefore ends
# without the Supervisor hearing about it, however owner-bound its final
# message is. The Lead must `paseo send --no-wait` its Supervisor itself
# (roles/lead.md); when such a turn ends without that send, this hook
# forwards the Lead's final message to the Lead's parent (the Supervisor).
#
# Turns the Supervisor started are skipped: Paseo already notifies it.
# The opener of a turn carries no sender, so a Peer-started turn is
# recognised by the handback format (protocol/handback.md: a position and a
# terminal sentinel) or a Paseo/task notification. A miss means no forward
# (the Lead's own send still covers it); a false match means a duplicate.

[ "${ROOM_ROLE:-}" = "lead" ] || exit 0
[ -n "${PASEO_AGENT_ID:-}" ] || exit 0
command -v paseo >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0
command -v python3 >/dev/null 2>&1 || exit 0

payload="$(cat)"
transcript="$(jq -r '.transcript_path // empty' <<<"$payload" 2>/dev/null)"
[ -n "$transcript" ] && [ -f "$transcript" ] || exit 0

# The Supervisor is this Lead's parent, whatever provider it runs on
# (supervisor, droid-supervisor, gemini-supervisor, ...).
sup_id="$(paseo inspect "$PASEO_AGENT_ID" --json 2>/dev/null | jq -r '.ParentAgentId // empty')"
[ -n "$sup_id" ] || exit 0

log_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/telemetry"
mkdir -p "$log_dir"
log() {
  printf '{"ts":"%s","lead":"%s","supervisor":"%s","action":"%s"}\n' \
    "$(date -u +%FT%TZ)" "$PASEO_AGENT_ID" "$sup_id" "$1" >> "$log_dir/notify-on-stop.jsonl"
}

msg_file="$(mktemp "${TMPDIR:-/tmp}/lead-forward.XXXXXX")" || exit 0
trap 'rm -f "$msg_file"' EXIT

# Prints "forward", "sent", "supervisor-turn" or "empty"; writes the forward
# text to $msg_file when the verdict is "forward".
verdict="$(python3 - "$transcript" "$sup_id" "$PASEO_AGENT_ID" "$msg_file" <<'PY'
import json, re, sys

path, sup_id, lead_id, out = sys.argv[1:5]
LIMIT = 6000
PEER_OPENER = re.compile(
    r"<paseo-system>|<task-notification>"
    r"|\b(HANDBACK|REOPEN_REQUEST|DEPENDENCY_REQUEST|CONFIRM|PARTIAL|CHALLENGE|BLOCKED)\b"
    r"|^\s*(REPORT|SCOUT|REVIEW|INTEGRATED)\b")

entries = []
with open(path, encoding="utf-8", errors="replace") as f:
    for line in f:
        try:
            entries.append(json.loads(line))
        except ValueError:
            pass

def content(e):
    return (e.get("message") or {}).get("content")

def prompt_text(e):
    """Text of a user prompt that opens a turn, else None."""
    if e.get("type") != "user" or e.get("isMeta"):
        return None
    c = content(e)
    if isinstance(c, str):
        text = c
    elif isinstance(c, list):
        if any(b.get("type") == "tool_result" for b in c if isinstance(b, dict)):
            return None
        text = "".join(b.get("text", "") for b in c if isinstance(b, dict) and b.get("type") == "text")
    else:
        return None
    if not text or text.startswith("[Request interrupted"):
        return None
    return text

start = None
for i in range(len(entries) - 1, -1, -1):
    if prompt_text(entries[i]) is not None:
        start = i
        break
if start is None:
    print("empty"); sys.exit()

opener = prompt_text(entries[start])
turn = entries[start + 1:]

short = sup_id[:7]
for e in turn:
    if e.get("type") != "assistant" or not isinstance(content(e), list):
        continue
    for b in content(e):
        if isinstance(b, dict) and b.get("type") == "tool_use":
            raw = json.dumps(b.get("input"), ensure_ascii=False)
            if short in raw and ("paseo send" in raw or "send_agent_prompt" in raw or "send_agent_prompt" in b.get("name", "")):
                print("sent"); sys.exit()

if not PEER_OPENER.search(opener):
    print("supervisor-turn"); sys.exit()

# Final message: the text blocks after the turn's last tool result.
last_result = -1
for j, e in enumerate(turn):
    c = content(e)
    if e.get("type") == "user" and isinstance(c, list) and any(
            isinstance(b, dict) and b.get("type") == "tool_result" for b in c):
        last_result = j
final = "\n".join(
    b.get("text", "")
    for e in turn[last_result + 1:] if e.get("type") == "assistant" and isinstance(content(e), list)
    for b in content(e) if isinstance(b, dict) and b.get("type") == "text").strip()
if not final:
    print("empty"); sys.exit()
if len(final) > LIMIT:
    final = final[:LIMIT] + f"\n[truncated {len(final) - LIMIT} chars; full text: paseo logs {lead_id}]"

head = opener.strip().splitlines()[0][:160] if opener.strip() else ""
with open(out, "w", encoding="utf-8") as f:
    f.write(
        f"[Stop hook] Lead {lead_id} ended a turn that a Peer or a background task started "
        f"(opener: \"{head}\") without sending you its report. Paseo does not notify you of "
        f"such turns. The Lead's final message, verbatim:\n\n<lead-report>\n{final}\n</lead-report>")
print("forward")
PY
)"

# NOTIFY_ON_STOP_DRY_RUN=1: print the verdict and the message, send and log nothing.
if [ -n "${NOTIFY_ON_STOP_DRY_RUN:-}" ]; then
  printf '%s\n' "$verdict"
  [ "$verdict" = forward ] && cat "$msg_file"
  exit 0
fi

case "$verdict" in
  forward)
    if paseo send --no-wait --prompt-file "$msg_file" "$sup_id" >/dev/null 2>&1; then
      log "forwarded"
    else
      log "forward-failed"
    fi
    ;;
  *) log "${verdict:-error}" ;;
esac

exit 0
