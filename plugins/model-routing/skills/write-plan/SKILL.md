---
name: write-plan
description: Write a routed implementation plan (PLAN.md) where every task is scored and assigned a subagent tier, ready for /run-plan. Use when the user asks for an implementation or deployment plan for coding agents.
argument-hint: "<goal or path to spec>"
---

# Write a routed implementation plan

Input: $ARGUMENTS (a goal, an issue, or a path to a spec). If empty, ask for the goal.

## Steps

1. **Understand the repo cheaply.** Delegate lookups to `scout` (stack, test/lint commands, relevant modules, an existing example of each pattern you will need). Do not read large parts of the codebase in the main context.
2. **Clarify.** If the goal is a vague idea rather than a spec and `superpowers:brainstorming` is available, run it first and plan from the spec it produces. Otherwise, if the goal has product-level gaps (behaviour, scope, breaking changes), ask the human up to 3 focused questions. Engineering choices you can make yourself; record them under *Decisions*. Do not use `superpowers:writing-plans` — this skill replaces it in this stack.
3. **Large or ambiguous goal?** If you would score the whole goal ≥ 8 with the `routing-rubric` skill, delegate the design to `architect` and build the plan from its SUBTASKS.
4. **Break down** into tasks that each touch one concern, have testable acceptance criteria and one mechanical verify command.
5. **Score and route** every task with the `routing-rubric` skill. Show the five scores — the numbers make the routing auditable and let the human disagree with a specific axis.
6. **Order** tasks with `depends_on`. Put independent tasks in the same `parallel_group` only if they touch disjoint files.
7. **Write** the plan to `PLAN.md` at the repo root (or the path the user gives) using [PLAN.template.md](PLAN.template.md) (in this skill's directory) as the structure.
8. **Summarise** to the human: number of tasks per tier, which tasks need security review, decisions they must confirm, rough cost shape (e.g. "2×T0, 5×T1, 2×T2"). Ask them to approve or adjust tiers before `/run-plan`.

## Quality bar for tasks

- A task that needs the word "and" in its title probably should be two tasks.
- Acceptance criteria describe observable behaviour, not implementation ("returns 429 after 5 failed attempts in 60 s", not "add a counter").
- Every task names at least one existing file as the pattern to follow, or states "no precedent" (which raises N).
- No task is routed to Opus "just in case": justify every T2 with its scores or an override.
