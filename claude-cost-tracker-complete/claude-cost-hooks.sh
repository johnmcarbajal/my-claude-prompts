#!/bin/bash
#
# Claude Code Usage Hook
# Automatically track Claude Code usage with cost analysis
#
# Integration methods:
# 1. Manual: Source this file in your shell
# 2. Automatic: Add to .bashrc/.zshrc  
# 3. Claude Code: Set as pre/post task hooks
#

# Configuration
CLAUDE_COST_TRACKER="${HOME}/claude-cost"
CLAUDE_SESSIONS_DIR="${HOME}/.claude-sessions"

# Ensure tracking directory exists
mkdir -p "$CLAUDE_SESSIONS_DIR"

# Auto-detect Claude Code usage and start tracking
claude_code_start_tracking() {
    local session_name="${1:-$(basename $(pwd))-$(date +%H%M)}"
    local context="${2:-Claude Code session}"
    
    echo "🔍 Starting Claude cost tracking..."
    "$CLAUDE_COST_TRACKER" start "$session_name" "$context"
    
    # Save session context for hooks
    echo "export CLAUDE_SESSION_ACTIVE=true" > "$CLAUDE_SESSIONS_DIR/.env"
    echo "export CLAUDE_SESSION_NAME='$session_name'" >> "$CLAUDE_SESSIONS_DIR/.env"
}

# Quick usage logging with estimation
claude_code_log_usage() {
    local pattern="${1:-chat}"  # code, review, chat, debug
    local context="${2:-Auto-tracked usage}"
    
    if [[ -f "$CLAUDE_SESSIONS_DIR/.env" ]]; then
        source "$CLAUDE_SESSIONS_DIR/.env"
        if [[ "$CLAUDE_SESSION_ACTIVE" == "true" ]]; then
            "$CLAUDE_COST_TRACKER" quick "$pattern" "$context"
        fi
    fi
}

# End tracking and generate report
claude_code_end_tracking() {
    echo "📊 Ending Claude cost tracking..."
    "$CLAUDE_COST_TRACKER" end
    
    # Clean up session context
    rm -f "$CLAUDE_SESSIONS_DIR/.env"
    
    echo "💡 Tip: Review your session report in .claude-sessions/"
}

# Integration with common commands
alias claude-start='claude_code_start_tracking'
alias claude-log='claude_code_log_usage'
alias claude-end='claude_code_end_tracking'
alias claude-status='$CLAUDE_COST_TRACKER status'

# Git hook integration
claude_git_hook_pre_commit() {
    # Log when committing during Claude session
    if [[ -f "$CLAUDE_SESSIONS_DIR/.env" ]]; then
        source "$CLAUDE_SESSIONS_DIR/.env"
        if [[ "$CLAUDE_SESSION_ACTIVE" == "true" ]]; then
            commit_msg=$(git log -1 --pretty=%B 2>/dev/null || echo "Git commit")
            claude_code_log_usage "code" "Git commit: $commit_msg"
        fi
    fi
}

# Smart usage detection based on command patterns
claude_detect_usage_pattern() {
    local command_line="$1"
    
    case "$command_line" in
        *"implement"*|*"create"*|*"build"*|*"generate"*)
            echo "code"
            ;;
        *"review"*|*"audit"*|*"check"*|*"analyze"*)
            echo "review"
            ;;
        *"fix"*|*"debug"*|*"error"*|*"bug"*)
            echo "debug"
            ;;
        *)
            echo "chat"
            ;;
    esac
}

# Automatic cost tracking wrapper for Claude Code
claude_code_with_tracking() {
    local command="$*"
    local pattern=$(claude_detect_usage_pattern "$command")
    
    # Auto-start session if none active
    if [[ ! -f "$CLAUDE_SESSIONS_DIR/.env" ]]; then
        claude_code_start_tracking "$(basename $(pwd))" "Auto-started for: $command"
    fi
    
    # Run the actual command (this would be your Claude Code command)
    echo "🤖 Running: $command"
    # claude-code "$@"  # Uncomment when you have actual claude-code binary
    
    # Log the usage
    claude_code_log_usage "$pattern" "Command: $command"
}

# Helper function to show cost tips
claude_cost_tips() {
    echo "💡 Claude Cost Optimization Tips:"
    echo "  • Use Sonnet for routine coding tasks"
    echo "  • Use Haiku for simple questions/reviews"
    echo "  • Reserve Opus for complex architecture/analysis"
    echo "  • Break large sessions into focused chunks"
    echo "  • Track context switching costs"
    echo "  • Review reports to identify efficiency patterns"
}

# Session management helpers
claude_session_info() {
    if [[ -f "$CLAUDE_SESSIONS_DIR/.env" ]]; then
        source "$CLAUDE_SESSIONS_DIR/.env"
        if [[ "$CLAUDE_SESSION_ACTIVE" == "true" ]]; then
            echo "📊 Active Session: $CLAUDE_SESSION_NAME"
            "$CLAUDE_COST_TRACKER" status
        else
            echo "📊 No active session"
        fi
    else
        echo "📊 No active session"
    fi
}

# Export functions for use in other scripts
export -f claude_code_start_tracking
export -f claude_code_log_usage  
export -f claude_code_end_tracking
export -f claude_detect_usage_pattern
export -f claude_code_with_tracking

echo "🔧 Claude cost tracking hooks loaded!"
echo "Commands: claude-start, claude-log, claude-end, claude-status"
echo "Use 'claude_cost_tips' for optimization advice"
