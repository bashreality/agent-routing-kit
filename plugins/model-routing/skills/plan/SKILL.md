---
name: plan
description: Plan a feature with superpowers' plan format plus a model-routing line per task, ready for /build. Use when the user asks for an implementation plan or wants to build something multi-step.
argument-hint: "<what to build, or path to a spec>"
---

# /plan — superpowers plan + routing

Input: $ARGUMENTS. If empty, ask what to build.

1. **Spec.** If the input is a rough idea with open product questions, run `superpowers:brainstorming` to get a spec. If it is already concrete (a clear issue, a spec file, a well-defined change), skip brainstorming — it is the most expensive step and adds nothing to a settled spec.
2. **Repo facts.** Need file locations, test commands or patterns? Ask `scout` (Haiku) instead of reading the codebase yourself.
3. **Write the plan with `superpowers:writing-plans`**, with two changes:
   - In the header, replace the "For agentic workers" line with:
     `> **Execute with:** /model-routing:build (routed subagents). Steps use checkbox (- [ ]) syntax.`
   - Under each `### Task N:` heading, before **Files:**, add one routing line scored with the `routing-rubric` skill:
     `**Route:** T1 · implementer · A0 R1 S1 N0 V0 = 2 · gate: batch-review`
     Gates: `verify` (T0), `batch-review` (T1), `review` (T2), `review+security` (any R=2).
4. **Mechanical tasks.** Mark consecutive T0 tasks that touch unrelated files with the same `**Batch:** b1` line — /build runs a batch in one cheap subagent instead of one per task.
5. **Hand off.** Tell the user: plan path, task count per tier, tasks needing security review, decisions they must confirm. Then: "Review it, then run /model-routing:build." Do not offer superpowers' subagent-driven or native execution.
