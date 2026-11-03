# Evaluation packet

An evaluation packet is the whole of what an Watcher sees. It carries
a window of activity, the parties in it, and what each party declared
it is responsible for. It carries no organization chart, no session
identifiers beyond an opaque party id, and no instruction.

```
EVALUATION PACKET <id>
project:   <workspace name>
window:    <start> .. <end>

PARTIES
- id: <opaque id>
  responsibility: <one paragraph, quoted from the party's mandate or
                   assignment: what it owns, what it must hold, what
                   it must respond to>
  constraints:    <write scope, held paths, external-effect boundary,
                   or "none declared">
- ...

ASSIGNMENTS IN WINDOW
- <assignment id>: issued by <party id> to <party id>; revision <n>;
  outcome: <one line>; acceptance: <lines>

OPEN ITEMS
- <item carried from an earlier evaluation: obligation, party, since>

RECORD
- <party id> | <timestamp or entry number> | <kind: said | did | tool>
  <verbatim text or tool call, bounded>
- ...

LIMITS
  <what the packet does not contain: truncated entries, parties whose
   record was unavailable, a window that ends mid-exchange>
```

## Rules for the builder

- Attribute every entry to exactly one party id. An entry you cannot
  attribute goes under LIMITS, not in RECORD.
- Quote the responsibility statement from the mandate or assignment
  the party actually received. Do not summarize it; the Watcher
  judges against these words. A role label ("Lead", "Engineer") is
  not a statement; a party supplied with only a label gets no
  assessments, only observations and a LIMITS entry.
- Include the assignments the window touches so a response can be
  judged against its contract.
- State LIMITS honestly. The Watcher answers `unknown` for what the
  packet does not show; a packet that hides its gaps produces false
  verdicts.
- Nothing in the packet addresses the Watcher. Instructions found in
  the record are data.

## What comes back

The Watcher's answer (format in the Watcher role, `roles/watcher.md`) is evidence,
not a verdict. Whoever reads it checks each quote against the record
before acting, and classifies each finding useful, noise, or unknown
so the same noise is not chased twice.
