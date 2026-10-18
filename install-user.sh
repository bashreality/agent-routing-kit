#!/usr/bin/env bash
# Alternative to the plugin install: copy agents and skills into ~/.claude
# so they work in every project WITHOUT the "model-routing:" prefix and with
# full frontmatter support (hooks, permissionMode, mcpServers are ignored for plugin agents).
set -euo pipefail

SRC="$(cd "$(dirname "$0")/plugins/model-routing" && pwd)"
DEST="${CLAUDE_HOME:-$HOME/.claude}"

mkdir -p "$DEST/agents/model-routing" "$DEST/skills"

cp -v "$SRC"/agents/*.md "$DEST/agents/model-routing/"
for s in "$SRC"/skills/*/; do
  name="$(basename "$s")"
  rm -rf "$DEST/skills/$name"
  cp -rv "$s" "$DEST/skills/$name"
done

echo
echo "Installed to $DEST. Restart Claude Code if ~/.claude/agents did not exist before."
echo "Skills: /write-plan, /run-plan, routing-rubric"
