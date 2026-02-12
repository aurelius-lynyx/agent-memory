#!/bin/bash
# add-fact.sh — Append an atomic fact to an entity's items.json
# Usage: add-fact.sh <entity-slug> <entity-type> <content> <source> [sourceRef]
#
# Example:
#   add-fact.sh alice person "Alice started a new job at Acme Corp" conversation "session-123"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_HOME="${MEMORY_HOME:-$(dirname "$SCRIPT_DIR")}"
ENTITIES_DIR="${MEMORY_HOME}/entities"

ENTITY="$1"
ENTITY_TYPE="$2"
CONTENT="$3"
SOURCE="$4"
SOURCE_REF="${5:-}"

validate_slug() {
    local val="$1"
    local label="$2"
    if [[ ! "$val" =~ ^[a-z0-9][a-z0-9_-]*$ ]]; then
        echo "Error: $label must match ^[a-z0-9][a-z0-9_-]*$" >&2
        echo "Got: $val" >&2
        exit 1
    fi
}

validate_slug "$ENTITY" "entity-slug"

ENTITY_DIR="$ENTITIES_DIR/$ENTITY"
ITEMS_FILE="$ENTITY_DIR/items.json"

# Create entity directory if needed
mkdir -p "$ENTITY_DIR"

# Generate fact ID
FACT_ID="$(uuidgen | tr '[:upper:]' '[:lower:]')"
CREATED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Create items.json if it doesn't exist
if [ ! -f "$ITEMS_FILE" ]; then
    echo "[]" > "$ITEMS_FILE"
fi

# Build fact JSON
FACT=$(jq -n \
    --arg id "$FACT_ID" \
    --arg content "$CONTENT" \
    --arg source "$SOURCE" \
    --arg sourceRef "$SOURCE_REF" \
    --arg createdAt "$CREATED_AT" \
    --arg entityType "$ENTITY_TYPE" \
    '{
        id: $id,
        content: $content,
        source: $source,
        sourceRef: $sourceRef,
        entityType: $entityType,
        createdAt: $createdAt,
        status: "active",
        supersedes: null
    }')

# Append to items.json
tmp_file="$(mktemp "${ITEMS_FILE}.tmp.XXXXXX")"
jq --argjson fact "$FACT" '. += [$fact]' "$ITEMS_FILE" > "$tmp_file"
mv "$tmp_file" "$ITEMS_FILE"

echo "Added fact $FACT_ID to $ENTITY"
