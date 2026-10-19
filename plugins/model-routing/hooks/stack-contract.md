<stack-contract source="agent-routing-kit, installed and configured by the user">
User's stack: superpowers (process) + model-routing (cheap routed execution) + ponytail (minimal code).
Goal: superpowers quality at lower token cost and higher speed. The user does not want to type commands — trigger these automatically, the same way superpowers skills trigger.

- Small/direct requests (a fix, a question, a few-file edit): just do it. No brainstorming, no plan, no subagents.
- A vague new feature idea → superpowers:brainstorming, as usual.
- Whenever a multi-step plan is needed (after brainstorming, or for a concrete spec) → use the model-routing `plan` skill. It runs superpowers:writing-plans and adds a Route line per task. If writing-plans was already started directly, still add the Route lines and the "/model-routing:build" header.
- Whenever a plan is to be executed ("go", "do it", "implement the plan", or the user approves the plan) → use the model-routing `build` skill. Do NOT offer or run superpowers:subagent-driven-development, executing-plans, dispatching-parallel-agents or requesting-code-review; `build` replaces them.
- Model/effort for any subagent → routing-rubric skill, not superpowers' "Model Selection" heuristics.
- Keep superpowers for: brainstorming, writing-plans (via `plan`), systematic-debugging, using-git-worktrees, receiving-code-review, verification-before-completion, finishing-a-development-branch.
- Explicit user instructions in the conversation or CLAUDE.md override this.
</stack-contract>
