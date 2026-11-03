---
name: grilling
description: "Settles with the owner what new work should do before the Supervisor hands it to a Lead: questions in numbered rounds, each with a recommended answer, until nothing about what the project does or how it behaves is left assumed. Use when the owner brings new work, or a change to how the project behaves, that the ticket, the workspace protocol and earlier owner decisions do not already answer; not for a tiny change, an operational instruction (status, review, merge, relay), or work already settled with the owner."
---

# Grilling

The rule that matters most: what the project does is the owner's to say, how it is built is the
Lead's to decide, and no Lead receives the work until the owner agrees you have understood.

## What goes to the owner

Only what changes what the project does or how it behaves: who it is for, what happens in the cases
that matter, the rules its logic follows, what it will not do, and the words it is spoken of in.
Stack, design, tests, process and sequencing are the Lead's: neither ask the owner nor decide them
yourself. List each at the foot of the round under **Left to Lead**, one line each, so the owner can
still claim one.

A fact the ticket, the repository or the tools can give is never a question for the owner. Read
what the request itself points to (the ticket, the message it quotes); anything deeper is the
Lead's to find: list it under **Lead finds out**, and ask meanwhile the questions that do not hang
on it.

## Rounds

Map the request as a tree: every decision branches into the ones that hang on it. A round asks every
decision whose prerequisites are already settled, and no other: a question whose answer depends on
one still open in this round belongs to a later round. Number each, give your recommended answer, and
wait for the owner's answers before the next round.

```text
❓ **Q1 - <title>**: <the question, with the choices when there are some>

➡️ <your recommended answer, and why in a line>

---

❓ **Q2 - ...**

**Left to Lead:** <a technical choice the Lead will make, one line each>
**Lead finds out:** <a fact the Lead must establish, one line each>
```

Each answer reshapes the tree: recompute what can be asked now and ask that.

- **Sharpen vague words.** When the owner says "account", ask whether the customer or the user is
  meant, and propose the term to keep.
- **Test with a scenario.** When a rule is stated, invent the case at its edge and ask what happens
  there.
- **Say when the words disagree** with the ticket, an earlier owner decision or the workspace
  protocol, and ask which is right.

## Writing it down

Keep each settled answer in the owner's words, beside the question it answers; an answer that
changes an earlier one replaces it. When the work goes to the Lead, the handoff carries them
verbatim under **Settled with the owner**, apart from **Left to Lead** and **Lead finds out**, so the
Lead can tell the owner's words from yours. You write no project file: where the workspace protocol
keeps product decisions, recording them there is the Lead's.

## Ends in

Every branch visited, nothing about what the project does silently assumed, and the owner's
confirmation that you have understood. If the owner says to start before that, start, and name in the
handoff what is still open as the point where the Lead must ask.
