#!/bin/bash
# checkpoint-load.sh — Load the most recent checkpoint for a session
# Usage: checkpoint-load.sh <session-id>
#
# Outputs the path to the most recent checkpoint file.
# Returns exit code 1 if no checkpoint exists.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_HOME="${MEMORY_HOME:-$(dirname "$SCRIPT_DIR")}"
CHECKPOINTS_DIR="${MEMORY_HOME}/checkpoints"

SESSION_ID="$1"

validate_session_id() {
    local val="$1"
    if [[ ! "$val" =~ ^[a-zA-Z0-9][a-zA-Z0-9_.-]*$ ]]; then
        echo "Error: session-id must match ^[a-zA-Z0-9][a-zA-Z0-9_.-]*$" >&2
        echo "Got: $val" >&2
        exit 1
    fi
}

if [ -z "$SESSION_ID" ]; then
    echo "Error: session-id is required" >&2
    exit 1
fi

validate_session_id "$SESSION_ID"

SESSION_DIR="$CHECKPOINTS_DIR/$SESSION_ID"

if [ ! -d "$SESSION_DIR" ]; then
    echo "Error: no checkpoints found for session: $SESSION_ID" >&2
    exit 1
fi

LATEST=$(find "$SESSION_DIR" -name "*.json" -type f 2>/dev/null | sort -r | head -n 1)

if [ -z "$LATEST" ]; then
    echo "Error: no checkpoint files found for session: $SESSION_ID" >&2
    exit 1
fi

echo "$LATEST"
