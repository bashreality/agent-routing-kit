---
name: routing-rubric
description: Rubric for choosing which subagent (model + effort) handles a coding task. Use when writing or executing an implementation plan, or before delegating any coding task to a subagent.
---

# Model routing rubric

Goal: give each task to the **cheapest agent that will get it right the first time**. A failed cheap attempt plus a retry costs more than one correct attempt on a stronger agent, so route on risk and clarity, not only on size.

## 1. Score the task (0-2 per axis)

| Axis | 0 | 1 | 2 |
|---|---|---|---|
| **A — Ambiguity** | Exact change specified | Goal clear, some choices left | Goal or behaviour unclear |
| **R — Risk / blast radius** | Docs, tests, internal tooling, isolated UI | Business logic, shared utilities, public-facing but reversible | Auth/permissions, secrets, crypto, payments, PII, data migrations, concurrency, infra/IAM, public API contracts |
| **S — Scope** | 1-2 files, one function | One module, several files | Several modules or layers |
| **N — Novelty** | Same pattern exists in the repo | Similar pattern, needs adapting | No precedent, new library or approach |
| **V — Verifiability (inverted)** | Existing tests or a mechanical check cover it | Partial coverage, tests must be added | Hard to verify automatically (timing, UI feel, external systems) |

**Total = A + R + S + N + V (0-10).**

## 2. Map the score to a tier

| Total | Tier | Agent | Model / effort |
|---|---|---|---|
| 0-1 | **T0** mechanical | `worker-mechanical` | Haiku / low |
| 2-4 | **T1** standard | `implementer` | Sonnet / medium |
| 5-7 | **T2** complex | `implementer-senior` | Opus / high |
| 8-10 | **T3** design first | `architect` → split → re-score subtasks | Opus / high |

Support agents (not tiered): `scout` (lookup, Haiku/low), `verifier` (run checks, Haiku/low), `reviewer` (Opus/medium), `security-reviewer` (Opus/high), `debugger` (Opus/high, escalation only).

## 3. Overrides (apply after the table, strongest wins)

1. **R = 2** → minimum T2, and `security-reviewer` is mandatory. **R = 1** → minimum T1 (Haiku never touches business logic).
2. **A = 2** → do not implement. Send to `architect`, or ask the human if the gap is a product decision.
3. **S = 2** → split the task before routing. A task touching several modules is a plan smell.
4. **V = 2** → minimum T1 and a `reviewer` gate, because nothing automatic will catch mistakes.
5. **Previous attempt failed** → route one tier up (see escalation).
6. Pure lookup or "run the tests" → `scout` / `verifier`, never an implementer.

## 4. Effort fine-tuning

The table sets defaults. Adjust per invocation (Agent tool `effort` parameter, Claude Code ≥ 2.1.292) instead of creating new agents:

- Bump **one level** (medium→high, high→xhigh) when the task is on a hot path, the spec is long, or a reviewer flagged reasoning errors.
- Drop **one level** only for repetitive batches of identical T1 tasks after the first one passed review.
- `max` effort and the `fable` model are reserved for tasks the human explicitly approves — cost and latency are much higher.
- `CLAUDE_CODE_EFFORT_LEVEL` env var overrides everything; if it is set, per-agent effort has no effect.

## 5. Escalation ladder

```
attempt fails verify
  → retry SAME agent once, include the failure output in the brief
  → still failing → next tier up (T0→T1→T2), include both previous attempts
  → T2 fails twice → debugger
  → debugger BLOCKED/FAILED → stop, report to the human with evidence
```

`BLOCKED` (a missing decision) is not a failure. Never escalate a BLOCKED task — answer the question or ask the human.

## 6. Review gates

| Task | Gate |
|---|---|
| T0 | `verifier` only |
| T1 | `reviewer` once per batch of related T1 tasks (per phase) |
| T2 | `reviewer` per task |
| R = 2 | `security-reviewer` per task, in addition to the above |
| End of plan | `verifier` on the full suite + one `reviewer` pass over the whole diff |

Never downgrade a gate to save cost. Reviewers verify claims themselves; an implementer's PASS is not evidence.

## 7. Calibration examples

| Task | A R S N V | Total | Tier |
|---|---|---|---|
| Rename `getUser` → `fetchUser` everywhere | 0 0 1 0 0 | 1 | T0 |
| Add `GET /health` endpoint like existing `/version` | 0 0 0 0 0 | 0 | T0 |
| Add pagination to `/orders` following `/invoices` | 0 1 1 0 0 | 2 | T1 |
| Fix off-by-one in date filter, repro test given | 0 1 0 0 0 | 1 | T1 (override R=1) |
| Add retry with backoff to the email client | 1 1 1 1 1 | 5 | T2 |
| Rate-limit `/login` per IP and per account | 1 2 1 1 1 | 6 | T2 + security-reviewer |
| Zero-downtime migration splitting `users.name` | 1 2 1 1 1 | 6 | T2 + security-reviewer |
| "Add multi-tenancy" | 2 2 2 2 1 | 9 | T3 → architect |

## 8. Writing a good delegation brief

Subagents start with no conversation history. Every brief must be self-contained:

- **Goal** in one sentence, and why it matters.
- **Files** to touch and one existing example of the pattern to copy.
- **Acceptance criteria** — testable, numbered.
- **Verify** — the exact command.
- **Constraints** — what not to touch, conventions, versions.
- **Previous attempts** — output of failed attempts when escalating.

A vague brief to a strong model is worse than a precise brief to a cheap one.
