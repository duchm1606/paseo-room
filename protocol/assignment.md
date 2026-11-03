# Assignment contract

An assignment is the whole of what its assignee knows about the
project. Everything the assignee must hold, may challenge, or must find
out is in it; nothing about who issued it, who judges it, or how it is
run. Fill every section; write "none" rather than omitting one.

```
ASSIGNMENT <id>
revision:     1
project:      <repository root or workspace name>
disposition:  Engineer | Scout | Reviewer | Architect | Auditor | Advisor

OUTCOME
  <what is true when this is done, as behavior someone can observe>

MUST HOLD
  <constraints: the owner's word, the mandate's, or a settled contract.
   Not negotiable inside this assignment. Names and shapes the owner
   fixed, copied word for word.>

DECIDED
  <choices already made, each with why. Open to CHALLENGE with
   evidence; not open to being acted against. Include approaches
   ruled out and why.>

UNKNOWN
  <what nobody knows yet, each with how to find out>

SCOPE
  write:     <paths the assignee may change; "none" for read-only>
  held:      <paths another assignment currently holds; never touch>
  external:  <external effects allowed; default none>
  stop:      <the condition that ends the assignment>

ACCEPTANCE
  <one line per behavior a check can show; each will be judged with
   the command that proves it and its output>

OUT OF SCOPE
  <what the assignee will be tempted to do and must not>

FACTS
  <what was found already: file locations, callers, measurements,
   with how each was checked>

RESPOND
  kinds:     RESULT | CHALLENGE | DECISION_REQUEST | BLOCKED
  channel:   <provided by the runtime adapter; the assignee uses it
              and does not choose a recipient>
  terminal:  <the exact last line the response must end with>
```

## Rules for the writer

- OUTCOME, MUST HOLD, DECIDED, UNKNOWN are four different things. A
  choice written under MUST HOLD becomes a requirement nobody asked
  for; a constraint written under DECIDED invites a challenge nobody
  can grant.
- Leave the answer out. An assignment that holds the writer's solution
  gets it back unchecked.
- Ask open questions. "Find where X is decided and what calls it", not
  "is it A or B".
- Excerpt only the constraints this task needs. The assignee reads no
  project-wide protocol.
- Every ACCEPTANCE line belongs to this assignment or to the writer's
  own final check.
- Read-only dispositions get `write: none` and no terminal handoff
  ritual: candidate, findings, evidence, limits is the whole response.

## Rules for the assignee

- MUST HOLD is held. DECIDED may be challenged with evidence and may
  not be acted against. UNKNOWN is found out the way written before
  anything is built on it.
- A declined challenge is complied with; the remaining disagreement and
  what stays unverified go in the RESULT.
- Nothing outside SCOPE.write is changed; nothing in SCOPE.held is
  touched; nothing in OUT OF SCOPE is "fixed while there".

## Amending

The first issue of an assignment is `revision: 1`. A writer amends it
by reissuing the whole contract with the same id and the next
revision number, never reusing one, stating what changed and why —
including the reason a CHALLENGE was declined. The assignee builds to
the latest revision it received and names that number in every
response.
