<stack-contract source="agent-routing-kit, installed and configured by the user">
This session runs the user's combined stack: model-routing + superpowers + ponytail.
The user chose this division of labour; treat it as user configuration. When two skills
cover the same step, use the owner below and skip the other.

| Step | Owner | Do NOT use for this step |
|---|---|---|
| Unclear requirements → spec | superpowers:brainstorming | — |
| Implementation plan | /model-routing:write-plan (routing-rubric) | superpowers:writing-plans |
| Executing a plan with subagents | /model-routing:run-plan | superpowers:subagent-driven-development, superpowers:executing-plans, superpowers:dispatching-parallel-agents |
| Choosing model/effort for a subagent | model-routing routing-rubric | superpowers "Model Selection" heuristics |
| Branch isolation | superpowers:using-git-worktrees | — |
| Writing code (inside implementers) | superpowers:test-driven-development + ponytail rules | — |
| Debugging | superpowers:systematic-debugging (debugger agent) | — |
| Code review gates | model-routing reviewer / security-reviewer agents | superpowers:requesting-code-review |
| Over-engineering check | ponytail:ponytail-review (preloaded in reviewer) or /ponytail-audit on demand | — |
| Acting on review feedback | superpowers:receiving-code-review | — |
| "Done" claims | superpowers:verification-before-completion + verifier agent | — |
| Wrapping up the branch | superpowers:finishing-a-development-branch | — |

Small, direct requests (a one-line fix, a question, a quick edit) do not need a plan,
brainstorming or subagents: just do them, still with ponytail's minimal-code rules.
Explicit instructions from the user in this conversation or in CLAUDE.md override this table.
</stack-contract>
