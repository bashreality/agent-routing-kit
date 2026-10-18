---
name: run-plan
description: Execute a routed PLAN.md by dispatching each task to its assigned subagent tier, with verification gates, reviews and automatic escalation. Run only when the user explicitly asks.
argument-hint: "[path to PLAN.md] [--from T-xx] [--dry-run]"
disable-model-invocation: true
---

# Execute a routed plan

You are the **orchestrator**. You coordinate; subagents do the work. Keep your own context lean: never read large files or long logs yourself — delegate to `scout` and `verifier`.

Arguments: $ARGUMENTS — plan path (default `PLAN.md`), optional `--from T-xx` to resume, `--dry-run` to only print the dispatch table.

## 0. Pre-flight

1. Read the plan. Check every task has: tier, agent, acceptance, verify. Missing tier → score it now with the `routing-rubric` skill.
2. Re-check routing against the rubric overrides (R=2 → T2 + security-reviewer, A=2 → architect, S=2 → split). Fix the plan and tell the human what you changed and why.
3. Make sure work happens on a dedicated branch. If `superpowers:using-git-worktrees` is available, use it to create an isolated worktree for the plan; otherwise check the tree is clean and on a feature branch, and ask the human if not. This skill replaces `superpowers:subagent-driven-development` and `superpowers:executing-plans` — do not run them alongside it.
4. Print the dispatch table (id, title, agent, model/effort, depends_on, gate). With `--dry-run`, stop here.

## 1. Dispatch loop

For each ready task (all `depends_on` are DONE), in plan order:

1. **Brief.** Write a self-contained brief from the task: goal, files, pattern example, numbered acceptance criteria, verify command, constraints, and previous attempt output if any. The subagent has none of your context.
2. **Delegate** with the Agent tool to the agent named in the task (`subagent_type`; when installed as a plugin it may appear as `model-routing:<name>`). Pass `effort` only when the task overrides the default.
3. **Parallelism.** Tasks in the same `parallel_group` with disjoint files may run concurrently. If they could touch the same files, give each `isolation: "worktree"` or run them sequentially. Cap at 3-4 concurrent implementers.
4. **Read the structured report** (STATUS / VERIFY / ESCALATE). Do not trust it blindly:
   - `DONE` → run the task's verify via `verifier`. PASS → apply the review gate. FAIL → treat as failed.
   - `BLOCKED` → if you can answer from the plan or repo, answer and resume the same agent with `SendMessage`. If it is a product decision, ask the human. Never escalate a BLOCKED task.
   - `FAILED` → escalation ladder (rubric §5): retry same agent once with the failure, then one tier up, then `debugger`, then stop and report.
5. **Review gate** (rubric §6). `CHANGES_REQUIRED` → send the issues back to the **same** implementer (SendMessage), telling it to apply `superpowers:receiving-code-review` (verify each point, push back on wrong ones), then re-review. Two failed review rounds → escalate one tier.
6. **Record** progress in the plan's *Progress log*: task id, agent actually used, attempts, result, one-line note. This is how a human (or a later session with `--from`) sees what happened.
7. **Checkpoint.** After each phase, show the human a 3-5 line status. Ask before continuing only if something was escalated, blocked or re-scoped.

## 2. Finish

1. `verifier` on the full test/lint/typecheck suite.
2. One `reviewer` pass over the whole diff against the plan's goal (and `security-reviewer` if any task had R=2).
3. If ponytail is installed, mention `/ponytail-debt` when implementers deferred shortcuts, so they are not forgotten.
4. Final summary: tasks done, escalations (which tier was wrong — feed this back into future plans), open follow-ups, anything the human must decide. Apply `superpowers:verification-before-completion` to every claim in it.
5. Offer `superpowers:finishing-a-development-branch` (merge / PR / keep) if available. Do not commit or push unless the human asked.

## Rules

- You never implement tasks yourself, even "small" ones — that is how orchestrator context explodes. Exception: trivial plan-file edits.
- Never weaken a gate or skip verify to save cost or time.
- If 2+ tasks in a row needed escalation from the same tier, pause and suggest re-scoring the remaining tasks.
- Stop immediately and ask the human before anything destructive or irreversible (dropping data, force-push, deleting branches, running migrations outside local env).
