#!/bin/bash
# checkpoint-save.sh — Save a raw JSON snapshot for a session
# Usage: checkpoint-save.sh <session-id> <file>
#
# Copies the given file into memory/checkpoints/<session-id>/<timestamp>.json
# Checkpoints are raw JSON snapshots — no summarization or processing.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_HOME="${MEMORY_HOME:-$(dirname "$SCRIPT_DIR")}"
CHECKPOINTS_DIR="${MEMORY_HOME}/checkpoints"

SESSION_ID="$1"
SOURCE_FILE="$2"

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

if [ -z "$SOURCE_FILE" ] || [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: valid file path is required" >&2
    exit 1
fi

SESSION_DIR="$CHECKPOINTS_DIR/$SESSION_ID"
mkdir -p "$SESSION_DIR"

TIMESTAMP="$(date -u +%Y%m%d-%H%M%S)"
CHECKPOINT_FILE="$SESSION_DIR/${TIMESTAMP}.json"

cp "$SOURCE_FILE" "$CHECKPOINT_FILE"

echo "Checkpoint saved: $CHECKPOINT_FILE"
