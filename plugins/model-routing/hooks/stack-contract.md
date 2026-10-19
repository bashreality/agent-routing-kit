<stack-contract source="agent-routing-kit, installed and configured by the user">
User's stack: superpowers (process) + model-routing (cheap routed execution) + ponytail (minimal code).
Goal: superpowers quality at lower token cost and higher speed.

- Small/direct requests (a fix, a question, a few-file edit): just do it. No brainstorming, no plan, no subagents.
- Feature or multi-step work → /model-routing:plan (= brainstorming only if the idea is vague, then superpowers:writing-plans + a Route line per task).
- Executing a plan → /model-routing:build. It replaces superpowers:subagent-driven-development, executing-plans, dispatching-parallel-agents and requesting-code-review; do not run those.
- Model/effort for any subagent → routing-rubric skill, not superpowers' "Model Selection" heuristics.
- Keep using superpowers for: brainstorming, writing-plans, systematic-debugging, using-git-worktrees, receiving-code-review, verification-before-completion, finishing-a-development-branch.
- Explicit user instructions in the conversation or CLAUDE.md override this.
</stack-contract>
