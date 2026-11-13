---
name: grilling
description: "Settles with the owner what new work should do before a mandate is written: questions in numbered rounds, each with a recommended answer, until nothing about what the project does or how it behaves is left silently assumed. Use when the owner brings new work, or a change to how the project behaves, that no current mandate already answers; not for a tiny change, an answer to a pending decision request, a side question, or work already settled with the owner."
---

# Grilling

The rule that matters most: facts are yours to find, what the project does is the owner's to
say, how it is built is the project's to work out, and no mandate goes out until the owner
agrees you have understood.

## What goes to the owner

Only what changes what the project does or how it behaves: who it is for, what happens in the
cases that matter, the rules its logic follows, what it will not do, what it may cost, and the
words it is spoken of in.

Stack, design, tests, process and sequencing are not questions for the owner and not yours to
decide: they go under OPEN in the mandate. Where the owner has already chosen one, it is fixed;
ask what it is for, and carry that purpose beside it.

Where the owner's words leave a small gap and one reading is plainly meant, take that reading
and list it at the foot of the round under **Assumed**, one line each, so the owner can
overturn it. Do not ask.

A fact that current state or the repository can give you is never a question. Read only what
settles it, and ask the rest of the round meanwhile; only the questions that hang on that fact
wait for it.

## Rounds

Map the request as a tree: every decision branches into the ones that hang on it. A round asks
every decision whose prerequisites are already settled, and no other: a question whose answer
depends on one still open in this round belongs to a later round. Number each, give your
recommended answer, and wait for the owner's answers before the next round.

```text
**Q1 - <title>**: <the question, with the choices when there are some>
Recommended: <your answer, and why in a line>

**Q2 - ...**

**Assumed:** <each reading you took without asking, one line each>
```

Each answer reshapes the tree: recompute what can be asked now and ask that.

- **Sharpen vague words.** When the owner says "account", ask whether the customer or the user
  is meant, and propose the term to keep.
- **Test with a scenario.** When a rule is stated, invent the case at its edge and ask what
  happens there.
- **Say when the words disagree** with an earlier mandate, a settled decision, or the code, and
  ask which is right.
- **Stop at intent.** A question whose answer changes how it is built, not what the owner gets,
  is not asked here.

## Writing it down

Nothing is written into the project. Each settled answer becomes a line of the mandate, never a
quotation: behavior under OUTCOME; limits, and names, values and paths the owner fixed, copied
exactly, under FIXED; grants as action, target and limits under AUTHORITY; everything unsettled
under OPEN. An answer that changes an earlier one replaces its line, and a mandate already sent
goes out again at the next revision, saying what changed.

## Ends in

Every branch visited, nothing about what the project does silently assumed, and the owner's
confirmation of your read-back: the OUTCOME, FIXED, AUTHORITY and OPEN you are about to send,
in plain words. If the owner says to start before that, start, and name what is still open
under OPEN as the point where the project must ask.

---

Adapted from the `grilling` Supervisor skill of seatworks (MIT, Copyright (c) 2026 long7400;
licence text in `LICENSE.seatworks` beside this file). Changed for this room: answers land in
the mandate instead of a project CONTEXT.md, and technical choices are left open for the
project instead of being decided at intake.
