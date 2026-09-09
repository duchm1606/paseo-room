# Council mechanics — sealed / anonymous / shadow

> Alias: "dual design" = two sealed Architect seats with distinct
> mandates; "dual review" = two independent Reviewer seats (ideally
> across model tiers/providers) on one frozen candidate. Reference
> shape from Demonthorn's live Echo protocol: exactly two independent
> seats (one strong-reasoning high-effort, one coding-tier medium),
> Lead owns the binding verdict and routes accepted findings to the
> writable owner while that ownership remains valid.
>
> Full review runs three lanes (Demonthorn, 2026-08-09): the two
> dual-review seats above plus one `codex-review` OCR delegation lane
> (a dedicated Luna Max seat operating Alibaba open-code-review in
> delegation mode) on the same frozen candidate. The OCR lane yields
> rule-based, file-accounted evidence; it is never the macro
> (architectural/lifecycle) review and never replaces either
> dual-review seat. All three lanes hand findings to Lead, who alone
> issues the verdict.

> Read by the Lead when convening a council (TARGET law 6 defines when
> one is warranted). Source: Demonthorn thread analysis, 2026-08-05.

Four orthogonal mechanisms — none of them is itself an agent role, and
none guarantees what the others provide:

| Mechanism | Controls | Does NOT guarantee |
|---|---|---|
| `independent` | separate session/context, own reasoning source | uncorrelated errors |
| `sealed` | seats don't read each other's conclusions before checkpoint | hidden model/author identity |
| `anonymous` | arbiters don't know whose/which provider's artifact it is | independent reasoning |
| `shadow` | runs in parallel without direct effect or binding authority | being a Reviewer or Supervisor |

## Anonymous = practical blinding, not cryptography

Apply after the revision round: rename artifacts `Candidate X/Y`,
strip model/provider/session/author metadata from the arbiter view,
keep a sealed provenance map for the Lead, randomize or counterbalance
presentation order (LLM judges suffer position/verbosity/self-
enhancement bias). Writing style may still leak the source — accepted.

## The anonymous packet compiler is a protocol step, not a judge

Normalize + anonymize + preserve traceability into a frozen packet:
frozen question/rubric; per candidate: claims, assumptions, evidence,
strongest critique, revision; unresolved propositions; known unknowns.
The compiler never picks a winner, never merges candidates into a
compromise, never adds untraceable synthesis. It is a template, not an
agent or service.

## Shadow has three subtypes — never use bare "Shadow" in a brief

- **Workflow Shadow** — bounded process observer for one episode,
  hands back to the Lead; does not keep a notebook, does not replace
  the Supervisor.
- **Shadow Implementer** — parallel implementation analysis or
  candidate proposal; default no-write; any write requires a
  disposable isolated scope with an explicit lease. Never a second
  writer on a moving scope.
- **Council Shadow Arbiter** — second independent judge: same frozen
  packet, same rubric, no reading the primary verdict before
  submitting; hunts blind spots.

## Primary + shadow arbiters are evidence streams, not votes

Agreement is convergence evidence, not acceptance. Disagreement is
preserved exactly and the Lead checks the contested proposition, then
issues the one binding verdict. Judge diversity (different model
families) reduces intra-model bias but does not multiply authority —
two models agreeing does not make an unevidenced claim true.

## Council stays risk-selected

Research on multi-agent debate does not support making it default
ceremony (MAD protocols are unstable vs self-consistency and can
converge on wrong answers). Full shape, only for material unresolved
ambiguity:

```text
sealed independent proposals
→ symmetric challenge → revisions
→ anonymous packet
→ independent primary/shadow arbitration
→ disagreement packet
→ Lead binding verdict
```

## Artifacts — question, seat report, reconcile output

A council produces exactly three shapes. The Lead writes the first and
the last; every seat returns the middle one. It never ends with "the
majority chose A"; it ends with a rationale that has an owner.

```text
COUNCIL QUESTION
Decision owner: Lead
Binding question:
Why one lane is insufficient:        <justify the ceremony or don't open it>
Common evidence bundle:              <same for every seat>
Binding constraints:
Evaluation criteria:
Sealed first-view rule:              <no seat reads another before submitting>
Seat A mandate / Seat B mandate / (Seat C mandate):
Cross-examination questions:         <after first views only>
Reconcile deadline:
Final artifact:
```

```text
SEAT REPORT
Position:
Mechanism:
Evidence:
Assumptions:
Failure modes:
What would change my view:
Recommendation:
Confidence and unknowns:
Terminal sentinel:
```

```text
RECONCILE OUTPUT
Binding decision:
Decision owner:
Convergent evidence:
Material disagreements:
Why the minority view was accepted / rejected:
Proof required before implementation / acceptance:
Rollback / review trigger:
```
