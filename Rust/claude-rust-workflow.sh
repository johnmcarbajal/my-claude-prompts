#!/bin/bash

# claude-rust-workflow - Integration script for Claude Code workflows
# Automatically switches between rust-expert and rust-code-reviewer based on context

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUST_EXPERT_AGENT="rust-expert"
RUST_REVIEWER_AGENT="rust-code-reviewer"
HANDOFF_SCRIPT="$SCRIPT_DIR/rust-handoff"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[claude-rust-workflow]${NC} $1"
}

# Detect appropriate agent based on context
detect_agent_needed() {
    local context="$1"
    
    # Check for explicit agent requests
    if echo "$context" | grep -qi "review\|audit\|security\|analyze\|check"; then
        echo "reviewer"
        return
    fi
    
    if echo "$context" | grep -qi "implement\|create\|build\|develop\|code\|feature"; then
        echo "expert"
        return
    fi
    
    # Check git state for automatic detection
    local modified_files=$(git diff --name-only HEAD~1..HEAD 2>/dev/null | grep "\.rs$" | wc -l)
    local new_files=$(git status --porcelain 2>/dev/null | grep "^A.*\.rs$" | wc -l)
    local total_rust_files=$(find . -name "*.rs" -type f | wc -l)
    
    # If there are recent changes, default to review
    if [[ $modified_files -gt 0 ]]; then
        echo "reviewer"
        return
    fi
    
    # If it's a new project or very few files, default to development
    if [[ $total_rust_files -lt 5 ]] || [[ ! -f Cargo.toml ]]; then
        echo "expert"
        return
    fi
    
    # Default to expert for ambiguous cases
    echo "expert"
}

# Check for unsafe patterns that require immediate review
check_for_urgent_review() {
    local urgent_patterns=(
        "unsafe"
        "transmute"
        "from_raw"
        "set_len"
        "get_unchecked"
        "password.*=.*\".*\""
        "secret.*=.*\".*\""
        "api_key.*=.*\".*\""
    )
    
    for pattern in "${urgent_patterns[@]}"; do
        if git diff HEAD~1..HEAD -- "*.rs" 2>/dev/null | grep -qi "$pattern"; then
            log "${RED}🚨 URGENT: $pattern detected in recent changes${NC}"
            log "${RED}   Forcing rust-code-reviewer for security analysis${NC}"
            echo "reviewer"
            return
        fi
    done
    
    echo ""
}

# Main workflow function
run_rust_workflow() {
    local task_description="$1"
    local force_agent="${2:-}"
    
    log "🦀 Starting Rust workflow analysis"
    log "📝 Task: $task_description"
    
    # Check for urgent review needs first
    local urgent_review=$(check_for_urgent_review)
    if [[ -n "$urgent_review" ]]; then
        force_agent="reviewer"
    fi
    
    # Determine which agent to use
    local suggested_agent
    if [[ -n "$force_agent" ]]; then
        suggested_agent="$force_agent"
        log "🎯 Forced agent: $suggested_agent"
    else
        suggested_agent=$(detect_agent_needed "$task_description")
        log "🤖 Suggested agent: $suggested_agent"
    fi
    
    # Show current project context
    log "📊 Project context:"
    echo "  - Rust files: $(find . -name "*.rs" -type f | wc -l)"
    echo "  - Modified files: $(git diff --name-only HEAD~1..HEAD 2>/dev/null | grep "\.rs$" | wc -l || echo 0)"
    echo "  - Has Cargo.toml: $(test -f Cargo.toml && echo "Yes" || echo "No")"
    echo "  - Has unsafe code: $(grep -r "unsafe" --include="*.rs" . >/dev/null 2>&1 && echo "Yes" || echo "No")"
    
    # Execute handoff if needed
    if [[ -f ".rust_handoff.json" ]]; then
        local current_target=$(cat .rust_handoff.json | grep '"target_agent"' | cut -d'"' -f4)
        if [[ "$current_target" != "$suggested_agent" ]]; then
            log "🔄 Handoff required: current target is $current_target, need $suggested_agent"
            "$HANDOFF_SCRIPT" --to "$suggested_agent" --context "$task_description"
        else
            log "✅ Current handoff target matches suggested agent"
        fi
    else
        log "🆕 Creating initial handoff to $suggested_agent"
        "$HANDOFF_SCRIPT" --to "$suggested_agent" --context "$task_description"
    fi
    
    # Provide agent-specific guidance
    case "$suggested_agent" in
        "expert")
            log "${GREEN}🏗️  Activating rust-expert for development${NC}"
            echo ""
            echo "🎯 Development Focus Areas:"
            echo "  • Architecture and design patterns"
            echo "  • Implementation and code generation"
            echo "  • Performance optimization"
            echo "  • Testing strategies"
            echo "  • Documentation and examples"
            echo ""
            echo "💡 Next: Use 'claude-code --agent rust-expert' or load rust-expert.md"
            ;;
        "reviewer")
            log "${GREEN}🔍 Activating rust-code-reviewer for analysis${NC}"
            echo ""
            echo "🎯 Review Focus Areas:"
            echo "  • Memory safety validation"
            echo "  • Security vulnerability assessment"
            echo "  • Concurrency correctness"
            echo "  • Performance analysis"
            echo "  • Code quality review"
            echo ""
            echo "💡 Next: Use 'claude-code --agent rust-code-reviewer' or load rust-code-reviewer.md"
            ;;
    esac
    
    return 0
}

# Quick commands for common workflows
case "${1:-help}" in
    "review")
        log "🔍 Starting code review workflow"
        run_rust_workflow "Code review requested" "reviewer"
        ;;
    "develop")
        log "🏗️  Starting development workflow"
        run_rust_workflow "Development work requested" "expert"
        ;;
    "auto")
        shift
        task="${*:-Auto-detected workflow}"
        log "🤖 Auto-detecting workflow for: $task"
        run_rust_workflow "$task"
        ;;
    "status")
        log "📊 Current workflow status"
        "$HANDOFF_SCRIPT" --status
        ;;
    "clear")
        log "🧹 Clearing workflow state"
        "$HANDOFF_SCRIPT" --clear
        ;;
    "help"|*)
        cat << EOF
claude-rust-workflow - Intelligent Rust Agent Coordination

USAGE:
    claude-rust-workflow <command> [args]

COMMANDS:
    review              Force code review workflow (rust-code-reviewer)
    develop             Force development workflow (rust-expert)
    auto [description]  Auto-detect workflow based on context
    status              Show current workflow status
    clear               Clear workflow state
    help                Show this help

EXAMPLES:
    # Auto-detect based on git changes and context
    claude-rust-workflow auto "implement authentication module"
    
    # Force code review
    claude-rust-workflow review
    
    # Force development mode
    claude-rust-workflow develop
    
    # Check current status
    claude-rust-workflow status

INTEGRATION WITH CLAUDE CODE:
    # Add to your .claude/config or use directly
    claude-code --before-task "./claude-rust-workflow auto"
    
    # Or use specific workflows
    claude-code --agent rust-expert      # Development
    claude-code --agent rust-code-reviewer  # Review

WORKFLOW:
    1. 🤖 Analyzes project context and git state
    2. 🎯 Selects appropriate agent (expert vs reviewer)
    3. 🔄 Creates handoff context if needed
    4. 📋 Provides specific guidance for next steps
    5. ✅ Seamless transition between development and review
EOF
        ;;
esac
