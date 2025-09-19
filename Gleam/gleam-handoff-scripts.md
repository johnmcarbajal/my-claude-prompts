# Gleam Agent Handoff Scripts

## Core Handoff Scripts

### 1. Main Gleam Agent Coordinator (`gleam-handoff`)

```bash
#!/bin/bash
# gleam-handoff - Coordinate between Gleam agents
# Usage: gleam-handoff --to {expert|reviewer} --context "reason"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
GLEAM_CONTEXT_DIR="${PROJECT_ROOT}/.gleam_context"

# Create context directory if it doesn't exist
mkdir -p "${GLEAM_CONTEXT_DIR}/handoffs"

# Parse arguments
TARGET_AGENT=""
CONTEXT_MESSAGE=""
FORCE_ANALYSIS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --to)
            TARGET_AGENT="$2"
            shift 2
            ;;
        --context)
            CONTEXT_MESSAGE="$2"
            shift 2
            ;;
        --force-analysis)
            FORCE_ANALYSIS=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [[ -z "$TARGET_AGENT" ]]; then
    echo "Usage: gleam-handoff --to {expert|reviewer} --context \"reason\""
    exit 1
fi

# Validate target agent
case "$TARGET_AGENT" in
    expert|reviewer)
        ;;
    *)
        echo "Invalid target agent. Use 'expert' or 'reviewer'"
        exit 1
        ;;
esac

echo "🔄 Preparing handoff to gleam-${TARGET_AGENT}..."

# Create handoff context
create_handoff_context() {
    local target="$1"
    local context="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local handoff_file="${GLEAM_CONTEXT_DIR}/handoffs/.gleam_handoff.json"
    
    # Capture current Gleam project state
    local project_status=""
    if [[ -f "gleam.toml" ]]; then
        project_status="gleam_project"
    else
        project_status="no_gleam_project"
    fi
    
    # Get git information
    local git_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    local git_commit=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    local git_status=$(git status --porcelain 2>/dev/null | wc -l)
    
    # Check for recent Gleam changes
    local gleam_files_changed=0
    if git rev-parse --verify HEAD~5 >/dev/null 2>&1; then
        gleam_files_changed=$(git diff --name-only HEAD~5..HEAD | grep -c "\.gleam$" || echo "0")
    fi
    
    # Generate handoff JSON
    cat > "$handoff_file" <<EOF
{
  "handoff_timestamp": "$timestamp",
  "source_agent": "gleam-coordinator",
  "target_agent": "gleam-${target}",
  "context_message": "$context",
  "force_analysis": $FORCE_ANALYSIS,
  "project_status": {
    "type": "$project_status",
    "git_branch": "$git_branch",
    "git_commit": "$git_commit",
    "uncommitted_changes": $git_status,
    "gleam_files_modified": $gleam_files_changed
  },
  "handoff_reason": "$(determine_handoff_reason $target)",
  "expected_actions": $(generate_expected_actions $target)
}
EOF
    
    echo "📋 Handoff context created: $handoff_file"
    
    # Show handoff summary
    echo ""
    echo "📊 Handoff Summary:"
    echo "   Target: gleam-$target"
    echo "   Reason: $context"
    echo "   Project: $project_status"
    echo "   Branch: $git_branch ($git_commit)"
    echo "   Changes: $git_status uncommitted, $gleam_files_changed Gleam files modified"
}

determine_handoff_reason() {
    local target="$1"
    case "$target" in
        expert)
            if [[ -n "$CONTEXT_MESSAGE" ]]; then
                echo "development_needed"
            else
                echo "architecture_design"
            fi
            ;;
        reviewer)
            if [[ $FORCE_ANALYSIS == true ]]; then
                echo "forced_review"
            else
                echo "code_review"
            fi
            ;;
    esac
}

generate_expected_actions() {
    local target="$1"
    case "$target" in
        expert)
            cat <<'EOF'
[
  "analyze_project_structure",
  "design_architecture",
  "implement_core_types",
  "create_functional_patterns",
  "setup_actor_model",
  "write_tests"
]
EOF
            ;;
        reviewer)
            cat <<'EOF'
[
  "validate_functional_patterns",
  "check_type_safety",
  "review_pattern_matching",
  "assess_error_handling",
  "evaluate_actor_model",
  "performance_analysis"
]
EOF
            ;;
    esac
}

# Execute handoff creation
create_handoff_context "$TARGET_AGENT" "$CONTEXT_MESSAGE"

# Copy handoff file to expected location for target agent
cp "${GLEAM_CONTEXT_DIR}/handoffs/.gleam_handoff.json" "./.gleam_handoff.json"

echo ""
echo "✅ Handoff complete! Run gleam-${TARGET_AGENT} to activate the target agent."

# Optional: Auto-activate target agent if requested
if [[ "${AUTO_ACTIVATE:-false}" == "true" ]]; then
    echo ""
    echo "🚀 Auto-activating gleam-${TARGET_AGENT}..."
    exec "gleam-${TARGET_AGENT}"
fi
```

### 2. Expert Agent Activation (`gleam-expert`)

```bash
#!/bin/bash
# gleam-expert - Activate the Gleam development expert agent
# Usage: gleam-expert [--skip-analysis]

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
GLEAM_CONTEXT_DIR="${PROJECT_ROOT}/.gleam_context"

echo "🦀✨ Activating Gleam Expert Agent..."

# Check for handoff context
if [[ -f ".gleam_handoff.json" ]]; then
    echo "💥 Processing handoff from coordinator"
    HANDOFF_CONTEXT=$(cat .gleam_handoff.json)
    echo "Context: $(echo "$HANDOFF_CONTEXT" | jq -r '.context_message // "No message"')"
    echo "---"
fi

# Create agent status file
mkdir -p "${GLEAM_CONTEXT_DIR}/active"
cat > "${GLEAM_CONTEXT_DIR}/active/gleam-expert.json" <<EOF
{
  "agent": "gleam-expert",
  "activated_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "project_root": "$PROJECT_ROOT",
  "mode": "development"
}
EOF

# Skip analysis if requested
if [[ "${1:-}" == "--skip-analysis" ]]; then
    echo "⏩ Skipping initial analysis"
    echo "🎯 Gleam Expert ready for development tasks"
    exit 0
fi

# Execute the mandatory activation protocol from the expert specification
echo "✨ Analyzing Gleam project state..."

# Check git status
echo "📊 Git repository status:"
git status --porcelain || echo "Not in a git repository"
echo ""

# Analyze recent changes with focus on Gleam patterns
echo "🔍 Gleam code analysis:"
if git log --oneline -5 >/dev/null 2>&1; then
    git log --oneline -5
    echo ""
    
    # Look for Gleam files in recent changes
    echo "📁 Recent Gleam file changes:"
    git diff --name-status HEAD~5..HEAD 2>/dev/null | while read status file; do
        case "$file" in
            gleam.toml)
                echo "📦 MANIFEST: $status $file"
                ;;
            *.gleam)
                echo "✨ GLEAM_CODE: $status $file"
                # Check for functional pattern concerns in the file
                if git show "HEAD:$file" 2>/dev/null | grep -q "panic\|todo\|assert"; then
                    echo "   ⚠️  PANIC_PRONE: Contains panic/todo/assert patterns"
                fi
                if git show "HEAD:$file" 2>/dev/null | grep -q "case.*_"; then
                    echo "   🔍 PATTERN_MATCHING: Catch-all patterns detected"
                fi
                ;;
            test/*|*_test.gleam)
                echo "🧪 TEST: $status $file"
                ;;
            *config*|*.toml|*.json)
                echo "⚙️ CONFIG: $status $file"
                ;;
        esac
    done
else
    echo "No git history available"
fi
echo ""

# Critical functional safety analysis
echo "🚨 Functional safety scan:"
if git diff HEAD~3..HEAD -- "*.gleam" 2>/dev/null | grep -n -E "(panic|todo\(\)|assert)"; then
    echo "⚠️  PANIC-PRONE CODE DETECTED - NEEDS ATTENTION"
else
    echo "✅ No panic-prone patterns detected"
fi

if git diff HEAD~3..HEAD -- "*.gleam" 2>/dev/null | grep -E "(case.*_|let.*=.*case)"; then
    echo "⚠️  PATTERN MATCHING COMPLEXITY - REVIEW FOR EXHAUSTIVENESS"
else
    echo "✅ No complex pattern matching detected"
fi

if git diff HEAD~3..HEAD -- "*.gleam" 2>/dev/null | grep -E "Error\(.*\)|Ok\(.*\)"; then
    echo "✅ Result type usage detected - good error handling patterns"
fi
echo ""

# Actor model integrity check
echo "🎭 Actor model analysis:"
if git diff HEAD~3..HEAD -- "*.gleam" 2>/dev/null | grep -E "(actor\.|Subject\(|process\.)"; then
    echo "📡 ACTOR PATTERNS DETECTED"
    if git diff HEAD~3..HEAD -- "*.gleam" 2>/dev/null | grep -E "(actor\.call|actor\.send)"; then
        echo "   📞 Message passing patterns found"
    fi
    if git diff HEAD~3..HEAD -- "*.gleam" 2>/dev/null | grep -E "(supervisor|start_link)"; then
        echo "   🌳 Supervision tree patterns found"
    fi
else
    echo "ℹ️ No actor model patterns detected"
fi
echo ""

# Dependency analysis
echo "📦 Dependency analysis:"
if [[ -f "gleam.toml" ]]; then
    echo "✅ Gleam project detected"
    if git diff HEAD~3..HEAD gleam.toml 2>/dev/null | grep "^\+"; then
        echo "📋 New dependencies added:"
        git diff HEAD~3..HEAD gleam.toml | grep "^\+" | grep -v "^\+++" | sed 's/^\+//' | head -5
        echo "⚠️  FUNCTIONAL PATTERN REVIEW REQUIRED for new dependencies"
    else
        echo "✅ No new dependencies"
    fi
else
    echo "❌ No gleam.toml found - not a Gleam project"
fi
echo ""

# Show recent code changes for development context
echo "📊 Recent code changes for development:"
if git diff --unified=3 HEAD~3..HEAD -- "*.gleam" >/dev/null 2>&1; then
    git diff --unified=3 HEAD~3..HEAD -- "*.gleam" | head -50
    if [[ $(git diff HEAD~3..HEAD -- "*.gleam" | wc -l) -gt 50 ]]; then
        echo "... (truncated - large changeset detected)"
    fi
else
    echo "No recent Gleam code changes"
fi
echo ""

echo "🎯 Gleam Expert Agent ready for:"
echo "   • Architecture design and planning"
echo "   • New Gleam code implementation"
echo "   • Functional pattern development"
echo "   • Actor model design"
echo "   • Type system architecture"
echo "   • Teaching and explanation"
echo ""
echo "💡 Ready to build, teach, and architect!"
```

### 3. Reviewer Agent Activation (`gleam-reviewer`)

```bash
#!/bin/bash
# gleam-reviewer - Activate the Gleam code review agent
# Usage: gleam-reviewer [--force-analysis]

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
GLEAM_CONTEXT_DIR="${PROJECT_ROOT}/.gleam_context"

echo "🔍✨ Activating Gleam Code Review Agent..."

# Check for handoff context
if [[ -f ".gleam_handoff.json" ]]; then
    echo "💥 Processing handoff from gleam-expert"
    HANDOFF_CONTEXT=$(cat .gleam_handoff.json)
    echo "Context: $(echo "$HANDOFF_CONTEXT" | jq -r '.context_message // "No message"')"
    echo "---"
fi

# Create agent status file
mkdir -p "${GLEAM_CONTEXT_DIR}/active"
cat > "${GLEAM_CONTEXT_DIR}/active/gleam-reviewer.json" <<EOF
{
  "agent": "gleam-reviewer",
  "activated_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "project_root": "$PROJECT_ROOT",
  "mode": "review"
}
EOF

# Execute the mandatory activation protocol from the reviewer specification
echo "✨ Analyzing Gleam project changes..."
git status --porcelain || echo "Not in a git repository"
echo ""

# Analyze recent changes with focus on functional patterns
echo "🔍 Functional pattern analysis:"
git diff --name-status HEAD~5..HEAD 2>/dev/null | while read status file; do
    case "$file" in
        gleam.toml)
            echo "📦 MANIFEST: $status $file"
            ;;
        *.gleam)
            echo "✨ GLEAM_CODE: $status $file"
            # Check for functional pattern concerns
            if git show "HEAD:$file" 2>/dev/null | grep -q "panic\|todo\|assert\|exit"; then
                echo "   ⚠️  PANIC_PRONE: Contains panic/todo/assert patterns"
            fi
            if git show "HEAD:$file" 2>/dev/null | grep -q "case.*_"; then
                echo "   🔍 PATTERN_MATCHING: Non-exhaustive patterns detected"
            fi
            ;;
        *config*|*.toml|*.json)
            echo "⚙️ CONFIG: $status $file"
            ;;
        test/*|*_test.gleam)
            echo "🧪 TEST: $status $file"
            ;;
    esac
done 2>/dev/null || echo "No recent changes to analyze"
echo ""

# Critical functional safety analysis
echo "🚨 Critical functional safety scan:"
if git diff HEAD~3..HEAD -- "*.gleam" 2>/dev/null | grep -n -E "(panic|todo\(\)|assert|exit)"; then
    echo "⚠️  PANIC-PRONE CODE DETECTED - MANDATORY REVIEW"
else
    echo "✅ No panic-prone patterns detected"
fi

if git diff HEAD~3..HEAD -- "*.gleam" 2>/dev/null | grep -E "(case.*_|let.*=.*case)"; then
    echo "⚠️  PATTERN MATCHING COMPLEXITY - REVIEW FOR EXHAUSTIVENESS"
else
    echo "✅ No complex pattern matching detected"
fi

if git diff HEAD~3..HEAD -- "*.gleam" 2>/dev/null | grep -E "Error\(.*\)|Ok\(.*\)"; then
    echo "✅ Result type usage detected - good error handling patterns"
fi
echo ""

# Actor model integrity check
echo "🎭 Actor model analysis:"
if git diff HEAD~3..HEAD -- "*.gleam" 2>/dev/null | grep -E "(actor\.|Subject\(|process\.)"; then
    echo "📡 ACTOR PATTERNS DETECTED"
    if git diff HEAD~3..HEAD -- "*.gleam" 2>/dev/null | grep -E "(actor\.call|actor\.send)"; then
        echo "   📞 Message passing patterns found"
    fi
    if git diff HEAD~3..HEAD -- "*.gleam" 2>/dev/null | grep -E "(supervisor|start_link)"; then
        echo "   🌳 Supervision tree patterns found"
    fi
else
    echo "ℹ️ No actor model patterns detected"
fi
echo ""

# Dependency analysis
echo "📦 Dependency analysis:"
if git diff HEAD~3..HEAD gleam.toml 2>/dev/null | grep "^\+"; then
    echo "📋 New dependencies added:"
    git diff HEAD~3..HEAD gleam.toml | grep "^\+" | grep -v "^\+++" | sed 's/^\+//'
    echo "⚠️  FUNCTIONAL PATTERN REVIEW REQUIRED for new dependencies"
else
    echo "✅ No new dependencies"
fi
echo ""

# Show code changes for analysis
echo "📊 Code changes for review:"
if git diff --unified=3 HEAD~3..HEAD -- "*.gleam" >/dev/null 2>&1; then
    git diff --unified=3 HEAD~3..HEAD -- "*.gleam" | head -100
    if [[ $(git diff HEAD~3..HEAD -- "*.gleam" | wc -l) -gt 100 ]]; then
        echo "... (truncated - large changeset detected)"
    fi
else
    echo "No recent Gleam code changes to review"
fi
echo ""

echo "🔍 Gleam Code Reviewer ready for:"
echo "   • Functional pattern validation"
echo "   • Type safety assessment"
echo "   • Pattern matching review"
echo "   • Error handling analysis"
echo "   • Actor model correctness"
echo "   • Performance evaluation"
echo ""
echo "💡 Ready to analyze, validate, and optimize!"
```

### 4. Utility Functions (`gleam-utils`)

```bash
#!/bin/bash
# gleam-utils - Utility functions for Gleam workflow

# Source this file or use individual functions

# Check if we're in a Gleam project
is_gleam_project() {
    [[ -f "gleam.toml" ]]
}

# Get current Gleam project name
get_gleam_project_name() {
    if is_gleam_project; then
        grep '^name' gleam.toml | cut -d'"' -f2 | head -1
    else
        echo "unknown"
    fi
}

# Check Gleam toolchain
check_gleam_toolchain() {
    echo "🔧 Gleam toolchain status:"
    
    if command -v gleam >/dev/null 2>&1; then
        echo "✅ Gleam: $(gleam --version)"
    else
        echo "❌ Gleam not installed"
    fi
    
    if command -v erl >/dev/null 2>&1; then
        echo "✅ Erlang: $(erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell)"
    else
        echo "❌ Erlang not installed"
    fi
    
    if command -v rebar3 >/dev/null 2>&1; then
        echo "✅ Rebar3: $(rebar3 --version)"
    else
        echo "ℹ️ Rebar3 not installed (optional)"
    fi
}

# Quick project health check
gleam_health_check() {
    echo "🏥 Gleam project health check:"
    
    if ! is_gleam_project; then
        echo "❌ Not a Gleam project (no gleam.toml)"
        return 1
    fi
    
    echo "✅ Valid Gleam project: $(get_gleam_project_name)"
    
    # Check if project compiles
    if gleam check >/dev/null 2>&1; then
        echo "✅ Project compiles successfully"
    else
        echo "❌ Compilation errors detected"
    fi
    
    # Check formatting
    if gleam format --check >/dev/null 2>&1; then
        echo "✅ Code is properly formatted"
    else
        echo "⚠️ Code formatting issues detected"
    fi
    
    # Check for tests
    if find . -name "*_test.gleam" -o -name "test/*.gleam" | grep -q "."; then
        echo "✅ Test files found"
        if gleam test >/dev/null 2>&1; then
            echo "✅ All tests passing"
        else
            echo "❌ Some tests failing"
        fi
    else
        echo "⚠️ No test files found"
    fi
}

# Clean up old handoff files
cleanup_handoffs() {
    local project_root="${1:-$(pwd)}"
    echo "🧹 Cleaning up old handoff files..."
    
    find "$project_root" -name ".gleam_handoff.json" -mtime +7 -delete 2>/dev/null || true
    find "$project_root/.gleam_context/handoffs" -name "*.json" -mtime +7 -delete 2>/dev/null || true
    
    echo "✅ Cleanup complete"
}

# Main utility runner
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-help}" in
        "check")
            check_gleam_toolchain
            echo ""
            gleam_health_check
            ;;
        "cleanup")
            cleanup_handoffs "${2:-$(pwd)}"
            ;;
        "project")
            if is_gleam_project; then
                echo "Project: $(get_gleam_project_name)"
            else
                echo "Not a Gleam project"
                exit 1
            fi
            ;;
        *)
            echo "Usage: gleam-utils {check|cleanup|project}"
            echo ""
            echo "Commands:"
            echo "  check   - Check toolchain and project health"
            echo "  cleanup - Clean up old handoff files"
            echo "  project - Get project information"
            ;;
    esac
fi
```

### 5. Installation Script (`install-gleam-workflow.sh`)

```bash
#!/bin/bash
# install-gleam-workflow.sh - Install Gleam agent workflow scripts

set -euo pipefail

INSTALL_DIR="${HOME}/.local/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🦄 Installing Gleam Agent Workflow Scripts..."

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Install main scripts
echo "📦 Installing handoff scripts..."
cp "${SCRIPT_DIR}/gleam-handoff" "${INSTALL_DIR}/"
cp "${SCRIPT_DIR}/gleam-expert" "${INSTALL_DIR}/"
cp "${SCRIPT_DIR}/gleam-reviewer" "${INSTALL_DIR}/"
cp "${SCRIPT_DIR}/gleam-utils" "${INSTALL_DIR}/"

# Make scripts executable
chmod +x "${INSTALL_DIR}/gleam-handoff"
chmod +x "${INSTALL_DIR}/gleam-expert"
chmod +x "${INSTALL_DIR}/gleam-reviewer"
chmod +x "${INSTALL_DIR}/gleam-utils"

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
```

## Usage Examples

### Development Workflow
```bash
# Start new development task
gleam-handoff --to expert --context "Implement user authentication system"
gleam-expert

# After implementation, hand off for review
gleam-handoff --to reviewer --context "Review auth implementation"
gleam-reviewer
```

### Review Workflow  
```bash
# Force comprehensive review
gleam-handoff --to reviewer --context "Security audit" --force-analysis
gleam-reviewer

# After fixes, back to development
gleam-handoff --to expert --context "Address review feedback"
gleam-expert
```

### Maintenance
```bash
# Check project and toolchain health
gleam-utils check

# Clean up old handoff files
gleam-utils cleanup

# Get project info
gleam-utils project
```
