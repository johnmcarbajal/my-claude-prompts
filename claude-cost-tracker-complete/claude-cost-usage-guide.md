# Claude Code Cost Tracking System

**Date**: 2025-09-13  
**Time**: 12:58:00 UTC

A comprehensive system for tracking Claude Code session costs, token usage, and generating detailed markdown reports for analysis and budgeting.

## Quick Setup

### 1. Installation
```bash
# Download the files to your project directory
# Make scripts executable
chmod +x claude-cost-tracker.py claude-cost claude-cost-hooks.sh

# Optional: Add to PATH for global access
export PATH="$PATH:$(pwd)"
```

### 2. Basic Usage
```bash
# Start a new session
./claude-cost start "JWT Development Session"

# Log token usage (input tokens, output tokens, context)
./claude-cost log 1500 800 "Implementing token validation"

# Quick logging with common patterns
./claude-cost quick code "Added authentication middleware"
./claude-cost quick review "Security audit of JWT handling"

# Check current session status
./claude-cost status

# End session and generate report
./claude-cost end
```

### 3. Advanced Integration
```bash
# Load hooks for automatic tracking
source claude-cost-hooks.sh

# Use aliases for convenience
claude-start "Session name"
claude-log code "What you worked on"  
claude-end
```

## Features

### 📊 Automatic Cost Calculation
- **Real-time pricing**: Uses current Anthropic pricing for all models
- **Model-specific rates**: Sonnet, Opus, Haiku pricing included
- **Input/Output breakdown**: Separate tracking for input and output costs
- **Running totals**: Session and project-wide cost accumulation

### 📈 Token Usage Analytics
- **Usage patterns**: Code generation, review, chat, debugging
- **Efficiency metrics**: Token per minute, input/output ratios
- **Model recommendations**: Suggests optimal model for tasks
- **Cost optimization**: Identifies high-cost patterns

### 📄 Comprehensive Reports
- **Markdown format**: Easy to read, version control friendly
- **Detailed activity log**: Timestamped usage with context
- **Cost analysis**: Hourly rates, efficiency insights
- **Session notes**: Space for your observations and next steps
- **Git integration**: Tracks commits during sessions

## Token Estimation Guide

### Rough Estimates
- **4 characters ≈ 1 token**
- **1,000 tokens ≈ 750 words**
- **Average function ≈ 50-200 tokens**
- **Small module ≈ 500-2,000 tokens**

### Common Usage Patterns
```bash
# Typical token ranges by activity
Simple chat/questions:     500-1,500 → 300-800 tokens
Code review:               1,000-3,000 → 500-1,500 tokens  
Feature implementation:    2,000-5,000 → 3,000-8,000 tokens
Architecture planning:     1,500-4,000 → 2,000-6,000 tokens
Security audit:           2,500-6,000 → 1,000-3,000 tokens
```

## Cost Optimization Strategies

### Model Selection
- **claude-haiku-3**: Simple questions, formatting, quick reviews ($0.25/$1.25)
- **claude-sonnet-4**: Most coding tasks, complex analysis ($3/$15)  
- **claude-opus-4**: Critical architecture, complex debugging only ($15/$75)

### Efficiency Tips
1. **Batch related requests** - Group similar tasks in one prompt
2. **Provide context upfront** - Reduce back-and-forth clarification
3. **Use specific prompts** - Avoid generic "help me with X" requests
4. **Context management** - Include relevant code/docs in initial prompt
5. **Session planning** - Define clear objectives before starting

## Example Workflows

### Workflow 1: Feature Development
```bash
# Start focused session
./claude-cost start "User Authentication Feature"

# Architecture planning (typically higher input tokens)
./claude-cost log 2500 3500 "Designed JWT auth architecture"

# Implementation (high output for code generation)  
./claude-cost log 1800 4200 "Implemented token validation middleware"

# Testing (moderate both directions)
./claude-cost log 1200 1800 "Added comprehensive auth tests"

# Review and refinement
./claude-cost log 900 600 "Fixed edge cases and security issues"

# End with report
./claude-cost end
```

### Workflow 2: Code Review Session
```bash
# Start review session
./claude-cost start "Security Review - Payment System"

# Initial analysis (high input to provide code context)
./claude-cost log 4500 2200 "Analyzed payment processing security"

# Detailed findings (moderate both directions)
./claude-cost log 1800 2800 "Identified 3 security vulnerabilities" 

# Recommendations (higher output for detailed suggestions)
./claude-cost log 1200 3400 "Provided security improvement recommendations"

./claude-cost end
```

### Workflow 3: Quick Debugging
```bash
./claude-cost start "Debug Session - API Errors"
./claude-cost quick debug "Fixed JWT token parsing error"
./claude-cost quick debug "Resolved database connection timeout"  
./claude-cost end
```

## Integration Options

### Option 1: Manual Tracking
Use the command-line tools manually during your Claude Code sessions.

### Option 2: Shell Integration
```bash
# Add to ~/.bashrc or ~/.zshrc
source /path/to/claude-cost-hooks.sh

# Now use aliases
claude-start "Session name"
claude-log code "What you did"
claude-end
```

### Option 3: Git Hooks
```bash
# Pre-commit hook automatically logs when you commit during a session
cp claude-cost-hooks.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### Option 4: CI/CD Integration
```yaml
# Track costs in CI/CD pipelines
- name: Track Claude Usage
  run: |
    ./claude-cost start "CI Review Session"
    # ... claude code commands ...
    ./claude-cost end
```

## Report Analysis

### Generated Reports Include:
- **Session overview**: Duration, project, git state
- **Cost breakdown**: Input/output costs, total session cost
- **Usage patterns**: Operations and models used
- **Detailed activity log**: Timestamped entries with context
- **Efficiency analysis**: Hourly rates, token efficiency
- **Optimization insights**: Automatic recommendations
- **Session notes**: Space for your observations

### Cost Analysis Features:
- **Hourly rate calculation**: Total cost ÷ session duration
- **Token efficiency**: Input/output ratios for different tasks
- **Pattern recognition**: High-cost operations identification  
- **Model usage recommendations**: Suggests optimal model selection
- **Trend analysis**: Session-over-session improvement tracking

## Real-World Examples

### Example 1: $50 JWT Development Session
```markdown
**Session Name**: JWT Authentication Implementation
**Duration**: 2.5 hours
**Total Cost**: $47.25
**Key Metrics**: 
- 15,500 input tokens, 28,200 output tokens
- Average cost per hour: $18.90
- Models: 80% Sonnet-4, 20% Haiku-3
- Operations: 60% code_generation, 30% review, 10% debug
```

### Example 2: $5 Quick Review Session
```markdown  
**Session Name**: Security Code Review
**Duration**: 20 minutes  
**Total Cost**: $4.80
**Key Metrics**:
- 3,200 input tokens, 1,800 output tokens
- Efficient focused review with specific questions
- 100% Sonnet-4 for security analysis
- High input/output efficiency for targeted feedback
```

## Troubleshooting

### Common Issues

**Q**: Token estimates seem off  
**A**: Claude's tokenization can vary. Monitor actual usage vs estimates and adjust.

**Q**: High costs per session  
**A**: Consider breaking into smaller focused sessions, using Haiku for simple tasks.

**Q**: Reports not generating  
**A**: Check file permissions and ensure Python 3 is available.

**Q**: Git integration not working  
**A**: Ensure you're in a git repository and have proper permissions.

### Best Practices
1. **Start small**: Begin with short sessions to establish baseline costs
2. **Monitor patterns**: Review reports to identify expensive operations
3. **Optimize prompts**: More specific prompts = better efficiency
4. **Plan sessions**: Define clear objectives and scope
5. **Track trends**: Monitor cost efficiency improvements over time

---

This cost tracking system helps you maintain visibility into Claude Code expenses while optimizing your development workflow for both cost-effectiveness and productivity.
