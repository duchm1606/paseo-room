# Seat-only skills (reserved)

Empty on purpose. Claude seats currently see the operator's `~/.claude/skills`
through the profile `skills` symlink, because the role-gate allow-lists in
`runtime/hooks/role-gate.sh` are written against that exact skill set.

If a skill should exist only for seats (not for the operator's own sessions),
put it here and point the profile `skills` symlink in
`runtime/bin/claude-profile` at this directory instead — update the role-gate
lists in the same change.
