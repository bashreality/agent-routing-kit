# PLAN: <goal in one line>

- **Repo / branch:** <repo> / <feature-branch>
- **Spec / issue:** <link or path>
- **Stack & commands:** test `<cmd>` · lint `<cmd>` · typecheck `<cmd>` · build `<cmd>`
- **Status:** draft | approved | in progress | done

## Goal

<2-4 sentences: what changes for the user/system and why.>

## Decisions

| # | Decision | Chosen | Why | Owner |
|---|---|---|---|---|
| D1 | <e.g. rate-limit store> | <Redis> | <already in stack> | agent / **human to confirm** |

## Out of scope

- <explicitly not doing>

## Routing summary

| Tier | Agent | Model / effort | Tasks |
|---|---|---|---|
| T0 | worker-mechanical | Haiku / low | <ids> |
| T1 | implementer | Sonnet / medium | <ids> |
| T2 | implementer-senior | Opus / high | <ids> |
| T3 | architect | Opus / high | <ids or none> |
| Gate | security-reviewer | Opus / high | <ids with R=2> |

## Tasks

### Phase 1 — <name>

#### T-01: <title>

- **Scores:** A0 R0 S1 N0 V0 = **1**
- **Tier / agent:** T0 / `worker-mechanical`
- **Effort override:** — <or e.g. high, with reason>
- **Depends on:** —
- **Parallel group:** A
- **Files:** `<path>`, `<path>`
- **Pattern to follow:** `<existing file or "no precedent">`
- **Acceptance:**
  1. <observable, testable criterion>
  2. <...>
- **Verify:** `<exact command>`
- **Review gate:** verifier | reviewer | reviewer + security-reviewer

#### T-02: <title>

- **Scores:** A1 R2 S1 N1 V1 = **6** · override: R=2
- **Tier / agent:** T2 / `implementer-senior`
- **Effort override:** —
- **Depends on:** T-01
- **Parallel group:** —
- **Files:** `<path>`
- **Pattern to follow:** `<path>`
- **Acceptance:**
  1. <...>
- **Verify:** `<exact command>`
- **Review gate:** reviewer + security-reviewer

### Phase 2 — <name>

<...>

## Final gate

- [ ] `verifier`: full suite green
- [ ] `reviewer`: whole diff vs goal
- [ ] `security-reviewer`: required if any task has R=2
- [ ] Human: confirm decisions marked **human to confirm**

## Progress log

<!-- Filled in by /run-plan. One line per attempt. -->

| Task | Agent used | Attempt | Result | Note |
|---|---|---|---|---|
