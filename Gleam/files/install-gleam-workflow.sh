#!/bin/bash
# install-gleam-workflow.sh - Install Gleam agent workflow scripts

set -euo pipefail

INSTALL_DIR="${HOME}/.local/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🦄 Installing Gleam Agent Workflow Scripts..."

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Check if scripts exist in the current directory or script directory
find_script() {
    local script_name="$1"
    if [[ -f "$script_name" ]]; then
        echo "$PWD/$script_name"
    elif [[ -f "${SCRIPT_DIR}/$script_name" ]]; then
        echo "${SCRIPT_DIR}/$script_name"
    else
        echo ""
    fi
}

# Install main scripts
echo "📦 Installing handoff scripts..."

# Array of scripts to install
scripts=("gleam-handoff" "gleam-expert" "gleam-reviewer" "gleam-utils")

for script in "${scripts[@]}"; do
    script_path=$(find_script "$script")
    if [[ -n "$script_path" ]]; then
        echo "Installing: $script"
        cp "$script_path" "${INSTALL_DIR}/"
        chmod +x "${INSTALL_DIR}/$script"
    else
        echo "⚠️  Script not found: $script"
        echo "   Make sure $script is in the current directory"
    fi
done

echo "✅ Scripts installed to: $INSTALL_DIR"

# Check if directory is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ""
    echo "⚠️  Add $INSTALL_DIR to your PATH:"
    echo "   export PATH=\"\$PATH:$INSTALL_DIR\""
    echo ""
    echo "   Add this to your ~/.bashrc or ~/.zshrc"
fi

echo ""
echo "🎯 Installation complete! Available commands:"
echo "   gleam-handoff   - Coordinate agent handoffs"
echo "   gleam-expert    - Activate development expert"
echo "   gleam-reviewer  - Activate code reviewer"
echo "   gleam-utils     - Utility functions"
echo ""
echo "💡 Quick start:"
echo "   gleam-handoff --to expert --context \"Start new project\""
echo "   gleam-expert"
