---
name: build
description: Use when executing an implementation plan (superpowers format, with or without Route lines) — replaces subagent-driven-development and executing-plans with routed subagents, batched reviews and escalation.
argument-hint: "[plan path] [--from N] [--dry-run]"
---

# /build — routed execution

You are the orchestrator: you dispatch, check and record. You never implement tasks yourself and never read big files or logs — `scout` and `verifier` do that. This keeps your context small, which is where most tokens go.

Arguments: $ARGUMENTS — plan path (default: newest file in `docs/superpowers/plans/`), `--from N` to resume at Task N, `--dry-run` to print the dispatch table only.

## Start

1. Read the plan once. Any task without a **Route:** line → score it with the `routing-rubric` skill now.
2. Isolate: use `superpowers:using-git-worktrees` (or confirm a clean feature branch).
3. Print a compact table: task · agent · model/effort · gate · batch. `--dry-run` stops here.

## Loop

For each ready task, in order (independent tasks with disjoint **Files:** may run in parallel, max 3; use `isolation: "worktree"` if files could overlap):

1. **Brief = the task's own section, verbatim**, plus the plan's *Global Constraints* and the **Interfaces** of tasks it consumes. Do not rewrite or summarise the task — the plan is already written for a fresh agent.
2. **Dispatch** to the routed agent (`model-routing:<agent>`). A `**Batch:**` group of T0 tasks goes to one `worker-mechanical` call.
3. **Check the report:**
   - `DONE` → T0: trust the agent's VERIFY only if it shows the command and exit code; otherwise run `verifier`. T1+: run the task's verify via `verifier`.
   - `BLOCKED` → answer from the plan/repo and resume the same agent (SendMessage); product decisions go to the user. Never escalate BLOCKED.
   - `FAILED` → resume the same agent once with the failure → next tier up → `debugger` → stop and ask the user.
4. **Gates:**
   - `verify`: nothing more.
   - `batch-review`: one `reviewer` call at the end of each phase over all its T1 tasks.
   - `review`: `reviewer` per task. `review+security`: also `security-reviewer`.
   - `CHANGES_REQUIRED` → back to the same implementer (SendMessage) with the issues and "apply superpowers:receiving-code-review"; re-review only the changed files. Two failed rounds → one tier up.
5. **Tick** the task's checkboxes in the plan and append one line to a `## Progress` section at the end: `Task N · agent · attempts · result`.

## Finish

1. `verifier` on the full suite.
2. One `reviewer` pass over the whole branch diff (plus `security-reviewer` if any task had R=2).
3. Report in ≤ 8 lines: done, escalations (= tiers that were wrong), open items, `/ponytail-debt` if shortcuts were deferred. Every claim backed by a command you ran (`superpowers:verification-before-completion`).
4. Offer `superpowers:finishing-a-development-branch`. Never commit/push/merge unless the user asks. Stop and ask before anything destructive.
