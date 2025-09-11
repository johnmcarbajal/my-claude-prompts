# CLAUDE.md

**Date**: [INSERT_DATE_YYYY-MM-DD]  
**Time**: [INSERT_TIME_HH:MM:SS] UTC

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

[PROJECT_NAME] - [Brief description of what the project does]

**Current Status**: [Fresh project | Active development | Production ready | Maintenance mode]
**Architecture**: [Microservice | Library | CLI tool | Web service | System utility]

## Development Flexibility

### Active Development Stage
Since the system is in [STAGE], we have [FLEXIBILITY_LEVEL]:
- **Breaking Changes**: [OK | Requires versioning | Not allowed]
- **Schema Evolution**: [Can redesign freely | Requires migration | Locked]
- **Refactor Freely**: [Yes | With deprecation | No]
- **API Evolution**: [Modify freely | Semantic versioning | Strict compatibility]
- **Direct Updates**: [Change schemas directly | Migration required]

### What We Still Maintain
- **Production Quality Code**: All code should be production-ready quality
- **[DOMAIN_SPECIFIC_REQUIREMENT]**: [e.g., Financial precision with rust_decimal]
- **[ARCHITECTURE_PATTERN]**: [e.g., Event sourcing, CQRS, Clean architecture]
- **Test Coverage**: Keep comprehensive tests even while refactoring
- **Documentation**: Update docs to reflect current state

## Enhanced Agent Coordination System

We have a sophisticated handoff system with specialized agents for optimal development workflow:

### 🔧 Development Phase: `rust-expert` (v3.0)
**Specializes in**: Code generation, architecture design, teaching patterns
**Use for**:
- New feature implementation ([FEATURE_EXAMPLES])
- Architecture design decisions and system blueprints
- Learning Rust concepts and modern ecosystem patterns
- Project setup, scaffolding, and dependency management
- Modern ecosystem integration ([TECH_STACK])

**Activation patterns**:
```bash
# Direct activation for new development
claude-code --agent rust-expert

# Or use intelligent workflow automation
./claude-rust-workflow develop

# Auto-detection for "implement", "create", "build" requests
```

### 🔍 Review Phase: `rust-code-reviewer`
**Specializes in**: Security audits, quality assessment, production readiness
**Use for**:
- Security audits ([SECURITY_FOCUS_AREAS])
- Memory safety and concurrency validation
- Performance analysis and optimization recommendations
- Production deployment readiness assessment
- Dependency security and compliance auditing

**Activation patterns**:
```bash
# Direct activation for comprehensive review
claude-code --agent rust-code-reviewer

# Automatic handoff after development
rust-handoff --to reviewer --context "[FEATURE] implementation complete, needs [REVIEW_TYPE] audit"

# Auto-triggers for security-sensitive code, unsafe blocks, [DOMAIN_TRIGGERS]
```

### 🧠 Context Management: `context-manager-pro` (v2.0)
**Specializes in**: Long-running task coordination, git verification, project state management
**Use for**:
- Projects exceeding 10k tokens or complex multi-step workflows
- Multi-agent workflow coordination and state preservation
- Git state verification and implementation claim validation
- Context preservation across development sessions
- Cross-component integration planning

**Auto-activation**: Triggers automatically for complex, multi-step tasks and git verification needs

### Enhanced Prompt Patterns

#### For Development Tasks:
```
[CONTEXT] [PROJECT_NAME] - [specific component/feature]
[PHASE] development
[SECURITY-FOCUS] [Specify security requirements for this domain]
[SCOPE] [Specific deliverable with clear success criteria]
[HANDOFF-READY] [Specify if this should prepare for security review]
[MANDATORY CONSTRAINTS - ZERO TOLERANCE]
- NO TODO/FIXME/XXX comments - implement fully or don't include
- NO unimplemented!() or todo!() macros - implement fully or remove feature
- Code MUST compile with zero errors
[DOMAIN-SPECIFIC CONSTRAINTS]
- [Add domain-specific requirements like financial precision, real-time constraints, etc.]
```

#### For Security Reviews:
```
[CONTEXT] [PROJECT_NAME] - [implemented feature]
[PHASE] review
[SECURITY-FOCUS] [Specific security concerns for your domain]
[SCOPE] Comprehensive security audit with actionable findings
[PRIORITY] [Critical | High | Medium] - [domain-specific priority reasoning]
```

### Intelligent Workflow Patterns

#### Pattern 1: [DOMAIN] Feature Development → Security Review
```bash
# 1. Development phase (auto-detects [DOMAIN] context)
[CONTEXT] [PROJECT_NAME] - implement [FEATURE_TYPE]
[PHASE] development  
[SCOPE] Complete [SPECIFIC_DELIVERABLE]
[SECURITY-FOCUS] [Domain-specific security concerns]
[HANDOFF-READY] Yes, prepare for security review

# 2. Automatic handoff triggers
# System detects: [SECURITY_TRIGGERS]
# → Auto-handoff to rust-code-reviewer

# 3. Security review phase
[CONTEXT] [FEATURE] implemented
[PHASE] review
[SCOPE] Security audit focusing on [SPECIFIC_CONCERNS]
[PRIORITY] [PRIORITY_LEVEL] - [reasoning]
```

#### Pattern 2: Architecture Design → Implementation → Performance Review
```bash
# 1. Architecture planning
[CONTEXT] [PROJECT_NAME] - design [SYSTEM_COMPONENT]
[PHASE] development
[SCOPE] Design [ARCHITECTURE_PATTERN] with [REQUIREMENTS]
[REQUIREMENT] [Performance/scale requirements]

# 2. Implementation with performance focus
[CONTEXT] [ARCHITECTURE] approved
[PHASE] development  
[SCOPE] Implement [COMPONENT] with [TECH_CHOICES]
[HANDOFF-READY] Yes, needs performance and security review

# 3. Comprehensive review
[CONTEXT] [COMPONENT] implemented
[PHASE] review
[SCOPE] Performance analysis, memory safety, concurrency correctness
```

### Auto-Detection Intelligence

The system automatically switches agents based on:

1. **Security-sensitive patterns**: [DOMAIN_SECURITY_PATTERNS] → `rust-code-reviewer`
2. **Unsafe code blocks**: Raw pointers, transmute, FFI → `rust-code-reviewer`
3. **Implementation requests**: "implement", "create", "build" → `rust-expert`
4. **Complex coordination**: Multi-step, >10k tokens → `context-manager-pro`
5. **Git analysis**: Detects project phase and security-sensitive changes
6. **[DOMAIN_PATTERN]**: [Domain-specific triggers] → [Appropriate agent]

### Security-First Patterns for [PROJECT_DOMAIN]

Given our [DOMAIN] focus, always trigger security review for:
- **[SECURITY_AREA_1]**: [Specific concerns]
- **[SECURITY_AREA_2]**: [Specific concerns]
- **[SECURITY_AREA_3]**: [Specific concerns]
- **Input validation and sanitization**
- **Database query patterns** (SQL injection prevention)
- **Environment variable handling**
- **Error handling** (information leakage prevention)

### Success Patterns
- **Incremental security-aware development**: Each phase produces secure, testable code
- **Automatic security gates**: No [CRITICAL_CODE] bypasses security review
- **Git-verified implementations**: All claims verified against actual commits
- **Context preservation**: Seamless handoffs maintain security requirements and architectural decisions
- **Teaching-oriented**: Explanations include security implications and "why" behind decisions
- **Performance-aware**: [PERFORMANCE_REQUIREMENTS]

### Anti-Patterns to Avoid
- **Security shortcuts**: Never skip security review for "simple" [DOMAIN] changes
- **Manual agent coordination**: Let the system auto-detect optimal workflow
- **Context loss during handoffs**: Use proper handoff system to preserve requirements
- **Monolithic security reviews**: Break into focused, component-specific audits
- **Implementation without security consideration**: Always specify security requirements upfront

## Development Commands

```bash
# Build and test
cargo build
cargo test
cargo run

# Development tools
cargo fmt
cargo clippy
cargo check

# [DOMAIN]-specific tools
[DOMAIN_TOOLS]                       # Add domain-specific commands
cargo audit                          # Dependency vulnerability scanning
cargo deny check                     # License and security policy enforcement
[ADDITIONAL_TOOLS]                   # Add project-specific tools
```

**WARNING**: Always verify implementation claims against git commits. When documentation conflicts with git history: **Git history wins**.

## ⚠️ ENFORCEMENT MECHANISMS (MANDATORY)

### 🚨 Automatic Rejection Criteria
The following will cause **AUTOMATIC REJECTION** of any code:

```bash
# These checks run automatically on EVERY commit attempt
# ANY violation = commit BLOCKED

❌ ANY occurrence of "TODO", "FIXME", "XXX" in code
❌ ANY occurrence of unimplemented!() or todo!() macros
❌ ANY compilation errors
❌ Excessive warnings (>30)
❌ Security violations flagged by cargo audit
[DOMAIN_SPECIFIC_REJECTIONS]         # Add domain-specific rejection criteria
```

### 🛡️ Pre-Commit Hook Enhanced
```bash
# This repository has MANDATORY pre-commit hooks
# Located at: .githooks/pre-commit
# Activated via: git config core.hooksPath .githooks

# The hook will PREVENT commits if it finds:
# - TODO/FIXME/XXX comments
# - unimplemented!/todo!() macros
# - Compilation failures
# - Security vulnerabilities (cargo audit)
# - [DOMAIN_SPECIFIC_VIOLATIONS]
```

### ✅ Required Verification Before ANY Work
```bash
# Run BEFORE starting work:
./scripts/claude-compliance-check.sh

# Run AFTER making changes:
./scripts/claude-compliance-check.sh

# Enhanced checks for [PROJECT_DOMAIN]:
grep -r "TODO\|FIXME" src/ --include="*.rs" | wc -l              # Must be 0
grep -r "unimplemented!\|todo!" src/ --include="*.rs" | wc -l    # Must be 0
cargo check 2>&1 | grep -c "^error"                              # Must be 0
cargo audit --json | jq '.vulnerabilities | length'             # Must be 0
[DOMAIN_SPECIFIC_CHECKS]                                         # Add domain-specific checks
```

### 📋 Required Agent Instructions
When using ANY agent (rust-expert, rust-code-reviewer, context-manager-pro), **ALWAYS** include:
```
[MANDATORY CONSTRAINTS - ZERO TOLERANCE]
- NO TODO/FIXME/XXX comments - implement fully or don't include
- NO unimplemented!() or todo!() macros - implement fully or remove feature
- Code MUST compile with zero errors and zero security warnings
- If you cannot implement something fully, REMOVE IT ENTIRELY
- These are HARD REQUIREMENTS, not guidelines
[SECURITY REQUIREMENTS - [PROJECT_DOMAIN]]
- [DOMAIN_SECURITY_REQUIREMENT_1]
- [DOMAIN_SECURITY_REQUIREMENT_2]
- [DOMAIN_SECURITY_REQUIREMENT_3]
- No information leakage in error messages
```

### 🔴 Violation Consequences
- **Pre-commit hook**: Will BLOCK the commit
- **CI/CD pipeline**: Will FAIL the build
- **Code review**: Will be REJECTED
- **Time wasted**: Hours of rework
- **Cost impact**: Unnecessary token usage
- **Security risk**: Potential vulnerabilities in production

### 💡 How to Handle Incomplete Features
If you cannot fully implement something:
1. **DON'T** add TODO comments
2. **DON'T** use unimplemented!() or todo!()
3. **DON'T** [DOMAIN_SPECIFIC_DONT]
4. **DO** one of these:
   - Implement a minimal working version
   - Return a secure default
   - Remove the feature entirely
   - Throw a proper error with explanation (no information leakage)

**Example of what to do:**
```rust
// ❌ NEVER DO THIS:
fn [DOMAIN_FUNCTION](input: &str) -> Result<[RETURN_TYPE]> {
    todo!("Implement [FUNCTION] later")  // VIOLATION!
}

// ✅ DO THIS INSTEAD:
fn [DOMAIN_FUNCTION](input: &str) -> Result<[RETURN_TYPE]> {
    // Return secure error - no implementation details leaked
    Err([ERROR_TYPE]::[SECURE_ERROR_VARIANT])
}
```

**Remember**: It's better to have fewer features that are secure than more features with security holes.

## Documentation Standards

When creating any documentation files, always include at the top:
- **Date**: Current date in yyyy-mm-dd format
- **Time**: Actual UTC time in HH:MM:SS UTC format (use `date -u` command to get real time)

Example:
```markdown
# Document Title

**Date**: 2025-01-27
**Time**: 17:45:00 UTC
```

This applies to ALL generated markdown files including:
- Planning documents, Code reviews, Architecture documentation
- Security assessments, Meeting notes, Status reports, Technical specifications

**Rationale**: Precise timestamps enable better tracking of document evolution and decision timing.

## Architecture

### Core Components
[Describe your main architectural components]
- **[COMPONENT_1]**: [Description and responsibilities]
- **[COMPONENT_2]**: [Description and responsibilities]
- **[COMPONENT_3]**: [Description and responsibilities]
- **[SECURITY_LAYER]**: [Security-specific components]

### Key APIs to Implement
[List main APIs/interfaces - mark security-critical ones]
- `[HTTP_METHOD] [ENDPOINT]` - [Description] ([SECURITY_LEVEL])
- `[HTTP_METHOD] [ENDPOINT]` - [Description] ([SECURITY_LEVEL])
- `[HTTP_METHOD] [ENDPOINT]` - [Description] ([SECURITY_LEVEL])

### Database Schema
[Describe data layer with security considerations]
- **[DATABASE_TYPE]**: [Tables/collections] with [security features]
- **[CACHE_TYPE]**: [Caching strategy] and [security considerations]
- **Security**: [Encryption, audit logging, etc.]

## [DOMAIN] Configuration

### [DOMAIN_SPECIFIC_CONFIG]
[Domain-specific configuration sections]
- **[CONFIG_AREA_1]**: [Requirements and security considerations]
- **[CONFIG_AREA_2]**: [Requirements and security considerations]

### Environment Variables
```bash
# [CATEGORY_1] (Security-sensitive)
[VAR_NAME_1]=[DESCRIPTION]
[VAR_NAME_2]=[DESCRIPTION]

# [CATEGORY_2] (Performance)
[VAR_NAME_3]=[DESCRIPTION]
[VAR_NAME_4]=[DESCRIPTION]

# Security settings
[SECURITY_VAR_1]=[DESCRIPTION]
[SECURITY_VAR_2]=[DESCRIPTION]

# Monitoring and logging
LOG_LEVEL=info
AUDIT_LOG_ENABLED=true
METRICS_ENABLED=true
```

### [DOMAIN] Limits and Protection
[Domain-specific rate limits, quotas, protections]
- **[LIMIT_TYPE_1]**: [Specific limits and reasoning]
- **[LIMIT_TYPE_2]**: [Specific limits and reasoning]
- **[PROTECTION_MECHANISM]**: [Description and configuration]

### Security Headers and [DOMAIN_PROTOCOL]
[Protocol-specific security configuration]
- [Security requirement 1]
- [Security requirement 2]
- Request/response logging for audit trails

## Current State

**Implementation**: [Current implementation status]
**Dependencies Needed**: 
- **Core**: [Essential dependencies]
- **[DOMAIN]**: [Domain-specific dependencies]
- **Security**: [Security-focused dependencies]
- **Database**: [Data layer dependencies]
- **Monitoring**: [Observability dependencies]
- **Testing**: [Testing framework dependencies]

**Next Priority**: [Immediate next steps with agent assignments]

---

## Template Usage Instructions

To use this template for a new Rust project:

1. **Replace all placeholders** in brackets `[PLACEHOLDER]` with project-specific values
2. **Customize security requirements** based on your domain (web service, CLI tool, embedded, etc.)
3. **Add domain-specific patterns** to the auto-detection intelligence
4. **Configure enforcement mechanisms** appropriate for your team and project
5. **Set up the actual scripts** referenced (compliance checks, pre-commit hooks)

### Key Customization Areas:

- **[PROJECT_NAME]**: Your project name
- **[PROJECT_DOMAIN]**: Your domain (web, CLI, embedded, financial, etc.)
- **[TECH_STACK]**: Your chosen dependencies and frameworks
- **[SECURITY_FOCUS_AREAS]**: Domain-specific security concerns
- **[DOMAIN_TRIGGERS]**: Patterns that should trigger security review
- **[PERFORMANCE_REQUIREMENTS]**: Your performance/scale requirements

This template provides a production-ready foundation for Rust projects with built-in security, quality, and coordination mechanisms.
