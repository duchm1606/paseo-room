---
name: research
description: >-
  Use when choosing packages, evaluating libraries, comparing technical options,
  or researching implementation approaches. Supports Quick (30s pick), Standard
  (5min comparison), and Deep (four sequential research lenses) modes. Produces
  CONTEXT.md for locked decisions, COMPARISON.md for package selection,
  RESEARCH.md for implementation guidance.
metadata:
  version: '1.0'
  ecosystem: swekit
  sources: gsd + khuym
  dependencies:
    - id: context7
      kind: mcp_server
      server_names: [context7]
      missing_effect: degraded
      reason: Primary source for library documentation.
---

# Research Skill

**One recommendation. Verified. Ready to use.**

Adapts gsd research patterns (research lenses, comparison tables, research gate).

## When to Use

- "What's the best library for X?"
- "Should I use A or B?"
- "How do I implement X?"
- Evaluating packages before adding dependencies
- Researching implementation approach for a phase

## Philosophy

**Training = Hypothesis.** Claude's knowledge is 6-18 months stale. Verify before asserting.

**Be opinionated.** "Use X because Y" not "Consider X or Y."

**Honest reporting.** "I couldn't find X" is valuable. LOW confidence is valuable. Don't hide uncertainty.

---

## Scope Tiers

Assess from the request + 30-second context scan:

| Tier | Trigger | Time | Output |
|------|---------|------|--------|
| **Quick** | Known category, low risk, "just pick one" | 30s-2min | Single recommendation + install |
| **Standard** | Comparison needed, moderate risk | 3-5min | COMPARISON.md with matrix |
| **Deep** | Strategic dependency, high risk, unknown domain | 10-20min | Four research lenses + RESEARCH.md + SUMMARY.md |

**Default to Standard.** Drop to Quick only if truly obvious. Escalate to Deep for strategic choices.

---

## Process Overview

```
[1] Scope Assessment (Quick/Standard/Deep)
     ↓
[2] Constraint Extraction (one question at a time)
     ↓
[3] Lock Constraints → CONTEXT.md
     ↓
[4] Research Phase (tool priority chain)
     ↓
[5] Comparison Matrix → COMPARISON.md
     ↓
[6] Research Gate (open questions resolved?)
     ↓
[7] Recommendation + Install snippet
     ↓
[8] Compound Learnings (if lesson learned)
```

---

## Phase 0: Scope Assessment

**Step 0.1 — Classify scope**

| Signal | Tier |
|--------|------|
| "Just pick one", known category, <3 options obvious | Quick |
| "Compare A vs B", need to justify choice, moderate risk | Standard |
| "What's the best approach", unknown domain, strategic dep | Deep |

**Step 0.2 — Load prior context**

```bash
cat history/learnings/critical-patterns.md 2>/dev/null || true
grep -r "tags:.*<domain-keyword>" history/learnings/ -l -i 2>/dev/null | head -5
```

Check for prior decisions in the same domain.

**Step 0.3 — Check for CONTEXT.md**

If `history/<topic>/CONTEXT.md` exists from a prior session, offer:
- Use existing constraints
- Update constraints
- Start fresh

---

## Phase 1: Constraint Extraction

**HARD-GATE: One question at a time. Wait for response before next question.**

### Domain Classification

What type of package/solution?

| Type | Examples | Key Probes |
|------|----------|------------|
| **UI** | Component libraries, styling | Bundle size, tree-shaking, design system fit |
| **DATA** | ORMs, validation, state | TypeScript support, performance, DX |
| **INFRA** | Build tools, testing, CI | Speed, config complexity, ecosystem |
| **NETWORK** | HTTP clients, WebSocket | Size, features, error handling |
| **UTIL** | Date, string, crypto | Size, tree-shaking, maintenance |

### Gray Area Probes (ask only what matters)

**For UI packages:**
- Bundle size critical? (frontend vs backend)
- Must integrate with existing design system?
- SSR/RSC compatibility needed?

**For DATA packages:**
- TypeScript-first required?
- Performance at scale matters?
- Existing ORM/validation to integrate with?

**For INFRA packages:**
- Speed vs features tradeoff preference?
- Team familiarity with alternatives?
- Must work with existing toolchain?

### Decision Locking

After each gray area resolved:
> "Locking constraint C{N}: {summary}. Confirmed?"

Assign stable IDs: C1, C2, C3...

---

## Phase 2: Write CONTEXT.md

After constraints locked, write:

```markdown
# Research Context: {topic}

**Date:** YYYY-MM-DD
**Scope:** Quick | Standard | Deep
**Domain:** UI | DATA | INFRA | NETWORK | UTIL

## Locked Constraints

- **C1:** {constraint}
- **C2:** {constraint}

## Claude's Discretion

- {areas where researcher can decide}

## Out of Scope

- {explicitly excluded considerations}
```

Save to: `history/<topic>/CONTEXT.md`

---

## Phase 3: Research Execution

### Tool Priority Chain

| Priority | Tool | Use For | Trust Level |
|----------|------|---------|-------------|
| 1st | Context7 | Library docs, API, features | **HIGH** — Primary source |
| 2nd | Exa MCP | Deep search, research papers | **HIGH** — Structured results |
| 3rd | Firecrawl MCP | Scrape official docs | **HIGH** — Direct source |
| 4th | Brave Search | Community patterns, discussions | **MEDIUM** — Verify claims |
| 5th | WebSearch | Fallback, ecosystem discovery | **LOW** — Cross-reference required |
| — | `npm view` | Stats verification | **AUTHORITATIVE** — Always run |
| — | bundlephobia | Bundle size verification | **AUTHORITATIVE** — Always run |

**Stats verification (npm/bundlephobia) runs ALWAYS, regardless of other tools.**

### Verification Commands

```bash
# Core stats (run for each candidate)
npm view $PKG version time.modified downloads-last-week repository.url

# Bundle size
curl -s "https://bundlephobia.com/api/size?package=$PKG" | jq '{size: .size, gzip: .gzip}'

# TypeScript support
npm view $PKG types typings | head -1
```

### Hard Disqualify Filters

Instant fail:
- Last update > 2 years ago
- < 1000 weekly downloads (unless niche)
- No TypeScript types (if TS project)
- Deprecated flag set
- Known security vulnerabilities

### Claim Provenance (CRITICAL)

Every factual claim must be tagged with one of three levels:

| Tag | Meaning | Example |
|-----|---------|---------|
| `[VERIFIED]` | Confirmed via authoritative source (npm, bundlephobia) | `[VERIFIED: npm]`, `[VERIFIED: bundlephobia]` |
| `[CITED: url]` | From documentation with URL | `[CITED: docs.zod.dev/guide]`, `[CITED: context7/zod]` |
| `[ASSUMED]` | Training knowledge, NOT verified | `[ASSUMED]` |

**Rules:**
- `[VERIFIED]` — Authoritative, can be locked immediately
- `[CITED: url]` — High confidence, reviewable by user
- `[ASSUMED]` — **Requires user confirmation before becoming locked decision**

**Never lock a decision based on `[ASSUMED]` claims without verification.**

---

## Phase 4: Thinking Models (Standard/Deep only)

Apply at decision points, not continuously.

### Survivorship Bias Counter

After gathering evidence FOR a package:
```bash
# Search for abandonment stories
WebSearch: "{package} migrated away from {year}"
WebSearch: "{package} problems at scale"
WebSearch: "{package} alternatives {year}"
```

Weight negative evidence MORE heavily — failures are underreported.

### Confirmation Bias Counter

After forming initial recommendation:
- Search AGAINST it: "{package} problems", "why not {package}"
- For each criticism found: refute with sources OR add as caveat

### First Principles Check

Before accepting any recommendation:
- What problem does this actually solve?
- What are the non-negotiable requirements from CONTEXT.md?
- Does this recommendation satisfy them from first principles?

---

## Phase 5: Comparison Matrix

### 5-Column Format (from gsd-advisor)

```markdown
## {Category} Comparison

| Option | Pros | Cons | Complexity | Recommendation |
|--------|------|------|------------|----------------|
| {pkg} | {pros} | {cons} | {impact + risk} | {conditional rec} |
```

**Column definitions:**
- **Option:** Package name + version
- **Pros:** Key advantages (comma-separated)
- **Cons:** Key disadvantages (comma-separated)
- **Complexity:** Impact surface + risk (e.g., "3 files, new dep — Risk: bundle size")
- **Recommendation:** Conditional ("Rec if mobile-first", "Rec if bundle size critical")

**Rules:**
- Complexity = impact surface + risk. NEVER time estimates.
- Recommendation = conditional. NEVER single-winner ranking in table.
- Only genuinely viable options — no padding.

### Calibration Tiers

| Tier | Options | Maturity Signals | Recommendations |
|------|---------|------------------|-----------------|
| **full_maturity** | 3-5 | Stars, age, ecosystem | Conditional, weighted to battle-tested |
| **standard** | 2-4 | Basic stats | Conditional |
| **minimal_decisive** | 2 max | Minimal | Single decisive pick |

### Verification Stats Table

```markdown
## Verification Stats

| Package | Version | Last Update | Downloads/wk | Bundle (gzip) | Types |
|---------|---------|-------------|--------------|---------------|-------|
| {pkg} | {ver} | {date} | {N} | {size} | {built-in/types/none} |
```

---

## Phase 6: Research Gate

**Block recommendation until resolved:**

1. Check `## Open Questions` section in COMPARISON.md
2. If unresolved questions exist → surface to user
3. If all resolved (or section marked `(RESOLVED)`) → proceed

```typescript
// Research gate logic
if (openQuestionsSection.exists && !openQuestionsSection.resolved) {
  return { pass: false, unresolvedQuestions: [...] };
}
return { pass: true };
```

---

## Phase 7: Final Recommendation

### Output Format

```markdown
## Recommendation

**Winner:** `{package-name}@{version}`

| Metric | Value | Source |
|--------|-------|--------|
| Version | {x.y.z} | [VERIFIED: npm] |
| Last updated | {date} | [VERIFIED: npm] |
| Downloads/week | {N} | [VERIFIED: npm] |
| Bundle size | {X} kB gzip | [VERIFIED: bundlephobia] |
| Types | {built-in / @types / none} | [VERIFIED: npm] |

**Why:** {One sentence rationale tied to CONTEXT.md constraints}

**Runner-up:** `{alt-package}` — {when to use instead}

## Confidence

| Area | Level | Reason |
|------|-------|--------|
| Recommendation | {HIGH/MEDIUM/LOW} | {source quality} |
| Alternatives | {HIGH/MEDIUM/LOW} | {coverage} |
| Risks | {HIGH/MEDIUM/LOW} | {verification depth} |
```

### Transition to Planning (CRITICAL)

**Research does NOT produce implementation code. Research outputs feed into planning.**

After recommendation is accepted:

1. **Save research artifacts** to `history/<topic>/`
2. **Invoke planning skill** with research context:
   ```
   Skill: writing-plans
   Context: Research complete for {topic}
   Input: COMPARISON.md + CONTEXT.md
   ```

3. **Planning phase** produces:
   - Implementation spec
   - Task breakdown
   - Integration points

**Flow:**
```
Research → COMPARISON.md → Planning → SPEC.md → Implementation
                ↓
          User approves
```

**Never skip to implementation. Research informs planning. Planning drives implementation.**

---

## Phase 8: Deep Mode — Four Research Lenses

For Deep tier only. Work four lenses one after another in this session — no
subagents, no issue tracker. Each lens writes its own file before the next
starts, so a later lens can build on an earlier one.

| Lens | Focus | Output |
|------|-------|--------|
| **Stack** | Core packages, versions, rationale | STACK.md |
| **Features** | Must-have vs nice-to-have | FEATURES.md |
| **Comparison** | Head-to-head analysis | COMPARISON.md |
| **Pitfalls** | Risks, gotchas, failures | PITFALLS.md |

### Synthesize Results

After all four lens files exist, read STACK + FEATURES + COMPARISON + PITFALLS → produces SUMMARY.md with:
- Executive summary (2-3 paragraphs)
- Key findings from each file
- Roadmap implications
- Confidence assessment
- Gaps to address

---

## State Management

### Files

```
history/<topic>/
  CONTEXT.md        ← Locked constraints
  COMPARISON.md     ← Package comparison matrix
  RESEARCH.md       ← Implementation research (Deep only)
  SUMMARY.md        ← Synthesized findings (Deep only)

history/learnings/
  critical-patterns.md  ← Promoted learnings
  YYYYMMDD-<slug>.md    ← Individual entries
```

### Context Budget

If context > 65%:
1. Write HANDOFF.json with current state
2. Note where to resume
3. Stop gracefully

---

## Compound Learnings

After research completes, if lesson learned:

```markdown
# history/learnings/YYYYMMDD-{topic}.md

---
tags: [package-selection, {domain}]
severity: standard | critical
---

## {Learning Title}

**Context:** {what was being researched}
**Finding:** {what was learned}
**Recommendation:** {what to do differently next time}
```

Promote to `critical-patterns.md` if:
- Affects multiple future decisions
- Would save ≥ 30 min if known in advance
- Is generalizable

---

## Quick Reference

### Quick Mode (30s-2min)

```
1. npm view {candidates} — stats check
2. Hard disqualify filter
3. Pick winner
4. Output: recommendation + install
```

### Standard Mode (3-5min)

```
1. Constraint extraction (1-3 questions)
2. Write CONTEXT.md
3. npm view + bundlephobia for candidates
4. Survivorship bias check
5. 5-column comparison table
6. Research gate check
7. Output: COMPARISON.md + recommendation
```

### Deep Mode (10-20min)

```
1. Full constraint extraction
2. Write CONTEXT.md
3. Work the four lenses in turn
4. Write STACK / FEATURES / COMPARISON / PITFALLS
5. Synthesize → SUMMARY.md
6. Research gate check
7. Output: full research artifacts + recommendation
```

---

## Anti-Patterns

| Don't | Do |
|-------|-----|
| "It depends on your needs" | Pick winner, explain when alternative wins |
| List 5+ options | Max 3: winner + 2 runners-up |
| Skip npm stats | Always verify: version, date, downloads |
| Trust training data | Verify with npm/bundlephobia/Context7 |
| Single-winner ranking in table | Conditional recommendations |
| Time estimates in Complexity | Impact surface + risk |

---

## Red Flags

Stop and reassess if:

- Recommending package > 2 years since last update
- Recommending package < 1000 weekly downloads without explanation
- Any `[ASSUMED]` claim becoming a locked decision without verification
- Skipping survivorship bias check for Standard/Deep
- Research gate has unresolved questions but proceeding anyway
- Synthesizing before all four lens files exist (Deep mode)

---

## References

- `references/gray-area-probes.md` — Domain-specific question banks
- `references/comparison-template.md` — 5-column table format
- `references/thinking-models.md` — Bias counters
- `references/tool-commands.md` — Verification commands
