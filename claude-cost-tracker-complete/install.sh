#!/bin/bash
#
# Claude Cost Tracker Installation Script
# Run this after extracting the archive
#

echo "🚀 Installing Claude Cost Tracker..."

# Make scripts executable
chmod +x claude-cost-tracker.py claude-cost claude-cost-hooks.sh

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed"
    echo "Please install Python 3 and try again"
    exit 1
fi

echo "✅ Made scripts executable"

# Test the installation
if ./claude-cost help > /dev/null 2>&1; then
    echo "✅ Installation successful!"
    echo ""
    echo "📖 Quick Start:"
    echo "  ./claude-cost start \"Session Name\""
    echo "  ./claude-cost log 1500 800 \"What you worked on\""
    echo "  ./claude-cost end"
    echo ""
    echo "📚 Read claude-cost-usage-guide.md for full documentation"
    echo ""
    echo "🔧 Optional: Add to PATH for global access:"
    echo "  export PATH=\"\$PATH:\$(pwd)\""
else
    echo "❌ Installation test failed"
    echo "Check that all files extracted correctly"
    exit 1
fi
