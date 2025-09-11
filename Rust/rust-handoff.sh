#!/bin/bash

# rust-handoff - Coordination script for rust-expert and rust-code-reviewer agents
# Usage: rust-handoff --to <target> --context "reason for handoff"

set -euo pipefail

# Configuration
HANDOFF_FILE=".rust_handoff.json"
LOG_FILE=".rust_handoff.log"
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG_FILE"
    echo -e "$1"
}

# Help function
show_help() {
    cat << EOF
rust-handoff - Rust Agent Coordination System

USAGE:
    rust-handoff --to <target> --context "<context>"
    rust-handoff --status
    rust-handoff --clear
    rust-handoff --help

OPTIONS:
    --to <target>          Target agent: 'expert' or 'reviewer'
    --context "<context>"  Reason for handoff (required)
    --status              Show current handoff status
    --clear               Clear handoff state
    --help                Show this help

EXAMPLES:
    # From reviewer to expert for new development
    rust-handoff --to expert --context "Security review complete, implement rate limiting feature"
    
    # From expert to reviewer for code review
    rust-handoff --to reviewer --context "Authentication module complete, needs security review"
    
    # Check current handoff status
    rust-handoff --status

WORKFLOW:
    1. rust-expert creates new code and implementations
    2. rust-handoff --to reviewer triggers security/quality review
    3. rust-code-reviewer analyzes and provides feedback
    4. rust-handoff --to expert for fixes or new development
EOF
}

# Detect current context
detect_current_context() {
    local context=""
    
    # Check git status for insights
    local git_status=$(git status --porcelain 2>/dev/null || echo "")
    local modified_files=$(echo "$git_status" | grep -E "\.rs$" | wc -l)
    local new_files=$(echo "$git_status" | grep "^A.*\.rs$" | wc -l)
    
    # Recent commits analysis
    local recent_commits=$(git log --oneline -5 2>/dev/null || echo "")
    
    # Build context information
    if [[ $modified_files -gt 0 ]]; then
        context="$modified_files Rust files modified"
    fi
    
    if [[ $new_files -gt 0 ]]; then
        context="$context, $new_files new files"
    fi
    
    # Check for specific patterns in recent commits
    if echo "$recent_commits" | grep -qi "implement\|add\|create"; then
        context="$context, recent implementation work"
    fi
    
    if echo "$recent_commits" | grep -qi "fix\|bug\|security"; then
        context="$context, recent fixes"
    fi
    
    if echo "$recent_commits" | grep -qi "test\|review"; then
        context="$context, recent testing/review work"
    fi
    
    echo "$context"
}

# Capture project state for handoff
capture_project_state() {
    local target_agent="$1"
    
    log "${BLUE}📸 Capturing project state for handoff to $target_agent${NC}"
    
    # Git state
    local git_commit=$(git rev-parse HEAD 2>/dev/null || echo "no-git")
    local git_branch=$(git branch --show-current 2>/dev/null || echo "no-branch")
    local git_status=$(git status --porcelain 2>/dev/null || echo "")
    
    # Recent changes
    local recent_changes=$(git diff --name-only HEAD~3..HEAD 2>/dev/null | grep "\.rs$" || echo "")
    
    # Project structure
    local rust_files=$(find . -name "*.rs" -type f | head -20)
    local cargo_present=$(test -f Cargo.toml && echo "true" || echo "false")
    
    # Detect project characteristics
    local async_usage=$(grep -r "async\|tokio\|futures" --include="*.rs" . 2>/dev/null | wc -l)
    local unsafe_usage=$(grep -r "unsafe" --include="*.rs" . 2>/dev/null | wc -l)
    local error_handling=$(grep -r "Result<\|Error\|anyhow\|thiserror" --include="*.rs" . 2>/dev/null | wc -l)
    
    cat > "$PROJECT_ROOT/project_state.json" << EOF
{
    "capture_timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "git": {
        "commit": "$git_commit",
        "branch": "$git_branch",
        "modified_files": $(echo "$git_status" | wc -l),
        "recent_rust_changes": [
            $(echo "$recent_changes" | head -10 | sed 's/.*/"&"/' | paste -sd "," -)
        ]
    },
    "project": {
        "cargo_present": $cargo_present,
        "rust_file_count": $(echo "$rust_files" | wc -l),
        "async_usage": $async_usage,
        "unsafe_usage": $unsafe_usage,
        "error_handling_usage": $error_handling
    },
    "focus_areas": {
        "has_async": $(test $async_usage -gt 0 && echo "true" || echo "false"),
        "has_unsafe": $(test $unsafe_usage -gt 0 && echo "true" || echo "false"),
        "complex_errors": $(test $error_handling -gt 10 && echo "true" || echo "false")
    }
}
EOF
}

# Create handoff context
create_handoff() {
    local target="$1"
    local context="$2"
    local source_agent="$3"
    
    # Validate target
    if [[ "$target" != "expert" && "$target" != "reviewer" ]]; then
        log "${RED}❌ Invalid target: $target. Must be 'expert' or 'reviewer'${NC}"
        exit 1
    fi
    
    # Auto-detect current context if not provided
    if [[ -z "$context" ]]; then
        context=$(detect_current_context)
        log "${YELLOW}⚠️  Auto-detected context: $context${NC}"
    fi
    
    # Capture project state
    capture_project_state "$target"
    
    # Create handoff metadata
    local handoff_data=$(cat << EOF
{
    "handoff_id": "$(date +%s)-$(echo $RANDOM | md5sum | head -c 8)",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "source_agent": "$source_agent",
    "target_agent": "$target",
    "context": "$context",
    "project_state_file": "$PROJECT_ROOT/project_state.json",
    "urgency": "normal",
    "handoff_reason": {
        "development_phase": "$(detect_development_phase)",
        "primary_need": "$(detect_primary_need "$target")",
        "context_summary": "$context"
    },
    "recommended_focus": $(generate_focus_recommendations "$target")
}
EOF
)
    
    echo "$handoff_data" > "$HANDOFF_FILE"
    
    log "${GREEN}✅ Handoff created: ${source_agent} → ${target}${NC}"
    log "${BLUE}📋 Context: $context${NC}"
    log "${BLUE}💾 Handoff file: $HANDOFF_FILE${NC}"
    
    # Show next steps
    show_next_steps "$target"
}

# Detect development phase
detect_development_phase() {
    local recent_commits=$(git log --oneline -10 2>/dev/null || echo "")
    
    if echo "$recent_commits" | grep -qi "initial\|first\|setup\|scaffold"; then
        echo "initialization"
    elif echo "$recent_commits" | grep -qi "implement\|add.*feature\|create"; then
        echo "development"
    elif echo "$recent_commits" | grep -qi "fix\|bug\|patch"; then
        echo "bugfix"
    elif echo "$recent_commits" | grep -qi "refactor\|cleanup\|optimize"; then
        echo "refactoring"
    elif echo "$recent_commits" | grep -qi "test\|review\|security"; then
        echo "validation"
    else
        echo "maintenance"
    fi
}

# Detect primary need based on target
detect_primary_need() {
    local target="$1"
    
    if [[ "$target" == "reviewer" ]]; then
        # Switching to reviewer - likely need analysis
        if git diff --name-only HEAD~1..HEAD | grep -q "\.rs$"; then
            echo "code_review"
        elif grep -r "unsafe" --include="*.rs" . >/dev/null 2>&1; then
            echo "security_audit"
        else
            echo "quality_assessment"
        fi
    else
        # Switching to expert - likely need development
        if [[ ! -f Cargo.toml ]]; then
            echo "project_setup"
        elif git status --porcelain | grep -q "\.rs$"; then
            echo "implementation_completion"
        else
            echo "feature_development"
        fi
    fi
}

# Generate focus recommendations
generate_focus_recommendations() {
    local target="$1"
    
    if [[ "$target" == "reviewer" ]]; then
        cat << 'EOF'
[
    "Memory safety validation",
    "Concurrency correctness",
    "Security vulnerability assessment",
    "Performance analysis",
    "Code quality review"
]
EOF
    else
        cat << 'EOF'
[
    "Architecture design",
    "Implementation planning",
    "Error handling strategy",
    "Testing approach",
    "Documentation creation"
]
EOF
    fi
}

# Show next steps based on target
show_next_steps() {
    local target="$1"
    
    echo ""
    log "${YELLOW}🎯 Next Steps for $target:${NC}"
    
    if [[ "$target" == "reviewer" ]]; then
        echo "1. 🔍 Run security analysis on modified files"
        echo "2. 🛡️  Check for memory safety issues"
        echo "3. ⚡ Analyze performance patterns"
        echo "4. 📋 Review code quality and idioms"
        echo "5. 🔒 Validate dependency security"
        echo ""
        echo "🤖 Activate rust-code-reviewer agent to begin analysis"
    else
        echo "1. 🏗️  Review handoff context and requirements"
        echo "2. 🎨 Design architecture for new features"
        echo "3. 💻 Implement core functionality"
        echo "4. 🧪 Create comprehensive tests"
        echo "5. 📚 Write documentation and examples"
        echo ""
        echo "🤖 Activate rust-expert agent to begin development"
    fi
}

# Show current handoff status
show_status() {
    if [[ ! -f "$HANDOFF_FILE" ]]; then
        log "${YELLOW}⚪ No active handoff${NC}"
        return
    fi
    
    local handoff_data=$(cat "$HANDOFF_FILE")
    local timestamp=$(echo "$handoff_data" | grep '"timestamp"' | cut -d'"' -f4)
    local source=$(echo "$handoff_data" | grep '"source_agent"' | cut -d'"' -f4)
    local target=$(echo "$handoff_data" | grep '"target_agent"' | cut -d'"' -f4)
    local context=$(echo "$handoff_data" | grep '"context"' | cut -d'"' -f4)
    
    log "${GREEN}🔄 Active Handoff${NC}"
    echo "  Timestamp: $timestamp"
    echo "  Direction: $source → $target"
    echo "  Context: $context"
    echo "  File: $HANDOFF_FILE"
    
    # Show file age
    local file_age_seconds=$(( $(date +%s) - $(stat -c %Y "$HANDOFF_FILE" 2>/dev/null || echo 0) ))
    local file_age_minutes=$(( file_age_seconds / 60 ))
    
    if [[ $file_age_minutes -gt 60 ]]; then
        echo "  Age: $((file_age_minutes / 60)) hours"
        log "${YELLOW}⚠️  Handoff is over 1 hour old${NC}"
    else
        echo "  Age: $file_age_minutes minutes"
    fi
}

# Clear handoff state
clear_handoff() {
    if [[ -f "$HANDOFF_FILE" ]]; then
        rm "$HANDOFF_FILE"
        log "${GREEN}✅ Handoff state cleared${NC}"
    else
        log "${YELLOW}⚪ No handoff state to clear${NC}"
    fi
    
    # Clean up temporary files
    if [[ -f "$PROJECT_ROOT/project_state.json" ]]; then
        rm "$PROJECT_ROOT/project_state.json"
        log "${GREEN}🧹 Cleaned up project state file${NC}"
    fi
}

# Auto-detect source agent based on context
detect_source_agent() {
    # Check recent git activity for clues
    local recent_commits=$(git log --oneline -5 2>/dev/null || echo "")
    
    if echo "$recent_commits" | grep -qi "review\|security\|audit\|fix"; then
        echo "rust-code-reviewer"
    elif echo "$recent_commits" | grep -qi "implement\|add\|create\|feature"; then
        echo "rust-expert"
    else
        echo "unknown"
    fi
}

# Main execution
main() {
    local target=""
    local context=""
    local action=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --to)
                target="$2"
                action="handoff"
                shift 2
                ;;
            --context)
                context="$2"
                shift 2
                ;;
            --status)
                action="status"
                shift
                ;;
            --clear)
                action="clear"
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                log "${RED}❌ Unknown option: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Execute action
    case "$action" in
        handoff)
            if [[ -z "$target" ]]; then
                log "${RED}❌ Target agent required. Use --to expert or --to reviewer${NC}"
                exit 1
            fi
            
            local source_agent=$(detect_source_agent)
            create_handoff "$target" "$context" "$source_agent"
            ;;
        status)
            show_status
            ;;
        clear)
            clear_handoff
            ;;
        *)
            log "${RED}❌ No action specified${NC}"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
