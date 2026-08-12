#!/bin/bash
# ccgs SessionStart hook: marker-gated bootstrap recovery.
# Does NOT scaffold a project on its own — only /ccgs:init does that.
# If the marker exists (user already ran /ccgs:init once), this silently
# recreates any missing scaffold directories/files so a project survives
# accidental deletion or a fresh git clone.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MARKER="$PROJECT_DIR/.ccgs/config.yaml"

if [ ! -f "$MARKER" ]; then
    echo "[ccgs] This project is not yet initialized for Claude Code Game Studios."
    echo "[ccgs] Run /ccgs:init to set it up, or ignore this if you're not using ccgs here."
    exit 0
fi

echo "=== Claude Code Game Studios (ccgs) ==="

VERSION=$(grep -m1 '^version:' "$MARKER" 2>/dev/null | sed 's/version: *"\?\([^"]*\)"\?/\1/')
if [ -n "$VERSION" ]; then
    echo "Marker version: $VERSION"
fi

BRANCH=$(git -C "$PROJECT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$BRANCH" ]; then
    echo "Branch: $BRANCH"
fi

# Idempotent recovery: recreate any missing scaffold directories.
RECOVERED=""
for d in design/gdd production/sprints production/milestones production/session-state production/session-logs docs/architecture tests/unit tests/integration tests/playtest src assets; do
    if [ ! -d "$PROJECT_DIR/$d" ]; then
        mkdir -p "$PROJECT_DIR/$d"
        RECOVERED="$RECOVERED $d"
    fi
done
if [ -n "$RECOVERED" ]; then
    echo ""
    echo "[ccgs] Recovered missing directories:$RECOVERED"
fi

# Active session state recovery (same behavior as the template's own hook).
STATE_FILE="$PROJECT_DIR/production/session-state/active.md"
if [ -f "$STATE_FILE" ]; then
    echo ""
    echo "=== ACTIVE SESSION STATE DETECTED ==="
    echo "A previous session left state at: production/session-state/active.md"
    echo "Read this file to recover context and continue where you left off."
fi

echo "==================================="
exit 0
