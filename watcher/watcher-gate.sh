#!/usr/bin/env bash
# agy PreToolUse gate for the Watcher seat. room-install links it, with
# hooks.json, into ~/.paseo/watcher/.agents/, which the provider `watcher`
# (hosts/mac.json) loads through --add-dir. The Watcher may run only
# read-only paseo commands; every other tool — file reads and writes
# included — is denied here, so its law does not rest on the model obeying.
payload="$(cat)"
name="$(jq -r '.toolCall.name // empty' <<<"$payload")"
cmd="$(jq -r '.toolCall.args.CommandLine // empty' <<<"$payload")"
allowed='^paseo (ls|logs|inspect)( [A-Za-z0-9_./:=,@+-]+)*$'
if [ "$name" = run_command ] && [[ "$cmd" =~ $allowed ]] \
   && ! [[ " $cmd " =~ \ (-f|--follow)\  ]]; then
  echo '{"decision":"allow"}'
  exit 0
fi
jq -cn --arg t "$name" '{decision: "deny", reason: ("The Watcher is read-only: only `paseo ls`, `paseo logs <id>` and `paseo inspect <id>` may run (no --follow). Denied: " + $t)}'
