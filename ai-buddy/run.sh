#!/bin/bash
# Launch Claude AI Buddy
# Usage: ./run.sh [--model sonnet|haiku|opus] [-m "question"]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check for Python 3
if ! command -v python3 &> /dev/null; then
    echo "Error: python3 is required but not found."
    exit 1
fi

# Install dependencies if needed
if ! python3 -c "import anthropic" 2>/dev/null; then
    echo "Installing dependencies..."
    pip install -r "$SCRIPT_DIR/requirements.txt"
fi

# Launch AI Buddy
python3 "$SCRIPT_DIR/buddy.py" "$@"
