#!/usr/bin/env bash
# agy PreToolUse gate for the Watcher seat. room-install links it, with
# hooks.json, into ~/.paseo/watcher/.agents/, which the provider `watcher`
# (hosts/mac.json) loads through --add-dir. The Watcher may run only
# read-only paseo commands, plus heartbeat commands on its own heartbeat
# (paseo scopes those to PASEO_AGENT_ID); every other tool — file reads and
# writes, paseo send, any other command — is denied here, so its law does
# not rest on the model obeying.
payload="$(cat)"
name="$(jq -r '.toolCall.name // empty' <<<"$payload")"
cmd="$(jq -r '.toolCall.args.CommandLine // empty' <<<"$payload")"
allow() { echo '{"decision":"allow"}'; exit 0; }

# A bare word carries no shell metacharacter; a single-quoted argument is
# literal to the shell whatever it holds. Nothing else is an argument.
word='[A-Za-z0-9_./:=,@+-]+'
q="'"
arg="($word|$q[^$q]*$q)"
read_re="^paseo (ls|logs|inspect)( $word)*$"
beat_re="^paseo heartbeat (create|update|delete)( $arg)*$"

if [ "$name" = run_command ]; then
  if [[ "$cmd" =~ $read_re ]] && ! [[ " $cmd " =~ \ (-f|--follow)\  ]]; then
    allow
  fi
  if [[ "$cmd" =~ $beat_re ]]; then
    # A heartbeat the Watcher creates must end on its own: an expiry or a
    # run limit, read outside the quoted prompt.
    bare="$cmd"
    while [[ "$bare" =~ ^(.*)$q[^$q]*$q(.*)$ ]]; do bare="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"; done
    case "$cmd" in
      "paseo heartbeat create "*) [[ " $bare " =~ \ --(expires-in|max-runs)\ [0-9] ]] && allow ;;
      *) allow ;;
    esac
  fi
fi
jq -cn --arg t "$name" '{decision: "deny", reason: ("The Watcher is read-only: only `paseo ls`, `paseo logs <id>` (no --follow), `paseo inspect <id>`, and `paseo heartbeat create|update|delete` on its own heartbeat may run; arguments are bare words or single-quoted, and a created heartbeat needs --expires-in or --max-runs. Denied: " + $t)}'
