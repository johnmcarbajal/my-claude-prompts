# Rust Agent Coordination System

A sophisticated handoff system for seamless coordination between specialized Rust development and code review agents in Claude Code workflows.

## Overview

This system provides two specialized agents with automatic coordination:

- **`rust-expert`** - Development specialist for code generation, architecture, and teaching
- **`rust-code-reviewer`** - Security and quality specialist for code analysis and review
- **`rust-handoff`** - Coordination script for seamless agent transitions
- **`claude-rust-workflow`** - Intelligent workflow automation

## Quick Start

### 1. Setup

```bash
# Make scripts executable
chmod +x rust-handoff claude-rust-workflow

# Add to PATH or use directly
export PATH="$PATH:$(pwd)"
```

### 2. Basic Usage

```bash
# Auto-detect workflow based on context
claude-rust-workflow auto "implement user authentication"

# Force specific workflows
claude-rust-workflow review    # Code review
claude-rust-workflow develop   # Development

# Check status
claude-rust-workflow status
```

### 3. Claude Code Integration

```bash
# Use specific agents
claude-code --agent rust-expert
claude-code --agent rust-code-reviewer

# Or integrate workflow automation
claude-code --before-task "./claude-rust-workflow auto"
```

## Agent Specializations

### 🏗️ rust-expert (Development Focus)

**Use for:**
- New feature implementation
- Architecture design
- Learning Rust concepts
- Project setup and scaffolding
- Performance optimization design

**Strengths:**
- Incremental development methodology
- Teaching-oriented explanations
- Modern Rust ecosystem knowledge
- Architecture and design patterns
- Zero-cost abstractions

**Example activation:**
```bash
rust-handoff --to expert --context "Need to implement JWT authentication system"
```

### 🔍 rust-code-reviewer (Analysis Focus)

**Use for:**
- Security audits
- Code quality assessment
- Memory safety validation
- Performance analysis
- Production readiness review

**Strengths:**
- Comprehensive security analysis
- Unsafe code validation
- Concurrency correctness
- Dependency security audit
- Production deployment validation

**Example activation:**
```bash
rust-handoff --to reviewer --context "Authentication module complete, needs security review"
```

## Handoff Protocol

### Automatic Handoff Triggers

The system automatically suggests handoffs based on:

1. **Git analysis** - Recent changes, commit patterns
2. **Code patterns** - Unsafe blocks, security-sensitive code
3. **Project phase** - Development vs maintenance
4. **Explicit requests** - "review", "implement", "analyze"

### Manual Handoff

```bash
# Explicit handoff with context
rust-handoff --to reviewer --context "Feature complete, needs security audit"

# Check current handoff status
rust-handoff --status

# Clear handoff state
rust-handoff --clear
```

### Handoff Data Structure

```json
{
  "handoff_id": "1706123456-a1b2c3d4",
  "timestamp": "2025-01-24T15:30:00Z",
  "source_agent": "rust-expert",
  "target_agent": "rust-code-reviewer",
  "context": "Authentication module complete, needs security review",
  "project_state_file": "/project/project_state.json",
  "urgency": "normal",
  "recommended_focus": [
    "Memory safety validation",
    "Security vulnerability assessment",
    "Concurrency correctness"
  ]
}
```

## Workflow Examples

### Example 1: New Feature Development

```bash
# 1. Start development
claude-rust-workflow develop
# → Activates rust-expert

# 2. Implement feature
# ... coding work ...

# 3. Switch to review
rust-handoff --to reviewer --context "User authentication complete"
# → Activates rust-code-reviewer

# 4. Review findings
# → Security analysis, performance review

# 5. Back to development for fixes
rust-handoff --to expert --context "Address security findings"
```

### Example 2: Security-First Review

```bash
# 1. Auto-detect (finds unsafe code)
claude-rust-workflow auto "check recent changes"
# → Automatically activates rust-code-reviewer

# 2. Comprehensive security analysis
# → Memory safety, concurrency, dependencies

# 3. Switch to expert for remediation
rust-handoff --to expert --context "Fix unsafe code patterns"
```

### Example 3: Continuous Integration

```bash
# In CI/CD pipeline
if git diff --name-only HEAD~1 | grep -q "\.rs$"; then
    claude-rust-workflow review
    # → Automated code review on changes
fi
```

## Security Features

### Automatic Security Detection

The system automatically triggers security review for:

- **Unsafe code blocks** - `unsafe`, `transmute`, `from_raw`
- **Sensitive patterns** - Hardcoded secrets, crypto usage
- **Concurrency risks** - Data races, deadlock patterns
- **Dependency changes** - New dependencies requiring audit

### Security Analysis Framework

```bash
# Comprehensive security scan
🚨 Critical Safety Scan:
├── Memory Safety Violations
├── Concurrency Issues  
├── Security Vulnerabilities
├── Dependency Security
└── Production Readiness
```

## Performance Monitoring

### Agent Performance Metrics

- **Context retrieval**: < 100ms for hot, < 500ms for warm
- **Git verification**: > 95% success rate  
- **Handoff latency**: < 2 seconds for context transfer
- **Analysis accuracy**: Comprehensive coverage of Rust-specific issues

### Context Management

```bash
# Context health check
rust-handoff --status

# Project state analysis
📊 Project Context:
├── Rust files: 42
├── Modified files: 3
├── Has unsafe code: Yes
├── Async usage: High
└── Security-sensitive: Yes
```

## Integration Patterns

### Claude Code Workflows

```bash
# .claude/config integration
{
  "before_task": "./claude-rust-workflow auto",
  "agents": {
    "rust-expert": "./rust-expert.md",
    "rust-code-reviewer": "./rust-code-reviewer.md"
  }
}
```

### Git Hooks Integration

```bash
# pre-commit hook
#!/bin/bash
if git diff --cached --name-only | grep -q "\.rs$"; then
    claude-rust-workflow review
fi
```

### CI/CD Integration

```yaml
# GitHub Actions example
- name: Rust Security Review
  run: |
    ./claude-rust-workflow review
    # Process review findings
```

## Troubleshooting

### Common Issues

1. **Handoff not triggering**
   ```bash
   # Check git status
   git status
   
   # Manual handoff
   rust-handoff --to expert --context "manual override"
   ```

2. **Agent confusion**
   ```bash
   # Clear state and restart
   rust-handoff --clear
   claude-rust-workflow auto "restart workflow"
   ```

3. **Context loss**
   ```bash
   # Check handoff file
   cat .rust_handoff.json
   
   # Regenerate context
   rust-handoff --to reviewer --context "regenerate context"
   ```

### Debugging

```bash
# Enable verbose logging
export RUST_WORKFLOW_DEBUG=1

# Check handoff logs
tail -f .rust_handoff.log

# Validate project state
cat project_state.json | jq '.'
```

## Best Practices

### Development Workflow

1. **Start with architecture** - Use `rust-expert` for design
2. **Implement incrementally** - Build → Test → Review cycles
3. **Security-first** - Automatic review for unsafe code
4. **Document decisions** - Handoff context preserves reasoning
5. **Continuous validation** - Regular security and quality checks

### Code Review Workflow

1. **Automated triggers** - Let the system detect review needs
2. **Comprehensive analysis** - Security, performance, quality
3. **Actionable feedback** - Specific, prioritized findings
4. **Iterative improvement** - Review → Fix → Re-review cycles
5. **Documentation** - Capture security and design decisions

### Production Deployment

1. **Final security audit** - Comprehensive review before release
2. **Dependency verification** - `cargo audit` and license checks
3. **Performance validation** - Benchmark critical paths
4. **Documentation complete** - Security and operational docs
5. **Monitoring ready** - Logs, metrics, alerts configured

## Advanced Features

### Context-Aware Analysis

The system maintains awareness of:
- **Project phase** (initialization, development, maintenance)
- **Code complexity** (async usage, unsafe blocks, error handling)
- **Security posture** (dependencies, crypto usage, input validation)
- **Performance characteristics** (hot paths, allocation patterns)

### Intelligent Recommendations

Based on analysis, the system provides:
- **Focused review areas** - High-priority security concerns
- **Architecture guidance** - Design pattern recommendations  
- **Performance optimization** - Bottleneck identification
- **Testing strategies** - Coverage and quality improvements

### Integration Ecosystem

Compatible with:
- **Claude Code** - Seamless agent switching
- **Git workflows** - Hooks and CI/CD integration
- **Cargo ecosystem** - `cargo audit`, `cargo clippy`, `cargo deny`
- **IDE integration** - VS Code, IntelliJ, Vim/Neovim
- **Monitoring tools** - Metrics and logging integration

---

This coordination system ensures that Rust development maintains the highest standards of safety, security, and performance while providing an efficient workflow for both new development and ongoing maintenance.
