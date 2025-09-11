# CLAUDE.md

**Date**: 2025-01-27  
**Time**: 17:45:00 UTC

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

JWT Authentication Service built in Rust - handles authentication, token generation/validation, and user management for distributed systems.

**Current Status**: Fresh project with comprehensive technical specs but minimal implementation
**Architecture**: Microservice with clean architecture principles

## Development Flexibility

### Active Development Stage
Since the system is in active development stage, we have significant flexibility:
- **Breaking Changes OK**: Can modify APIs, database schemas, and interfaces freely
- **Schema Evolution**: Can redesign data models and database tables
- **Refactor Freely**: Can restructure code, rename modules, change architectures
- **API Evolution**: Modify interfaces to be more intuitive without versioning constraints
- **Direct Updates**: Change database schemas directly when needed

### What We Still Maintain
- **Production Quality Code**: All code should be production-ready quality
- **Financial Precision**: Always use rust_decimal for monetary values
- **Event Sourcing Patterns**: Maintain immutable event store and CQRS architecture
- **Test Coverage**: Keep comprehensive tests even while refactoring
- **Documentation**: Update docs to reflect current state

## Enhanced Agent Coordination System

We now have a sophisticated handoff system with specialized agents for optimal development workflow:

### 🔧 Development Phase: `rust-expert` (v3.0)
**Specializes in**: Code generation, architecture design, teaching patterns
**Use for**:
- New feature implementation (authentication, JWT handling, session management)
- Architecture design decisions and system blueprints
- Learning Rust concepts and modern ecosystem patterns
- Project setup, scaffolding, and dependency management
- Modern ecosystem integration (tokio, axum, sqlx, redis)

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
- Security audits (critical for JWT/auth security)
- Memory safety and concurrency validation
- Performance analysis and optimization recommendations
- Production deployment readiness assessment
- Dependency security and compliance auditing

**Activation patterns**:
```bash
# Direct activation for comprehensive review
claude-code --agent rust-code-reviewer

# Automatic handoff after development
rust-handoff --to reviewer --context "JWT implementation complete, needs security audit"

# Auto-triggers for security-sensitive code, unsafe blocks, crypto usage
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
[CONTEXT] JWT Auth Service - [specific component/feature]
[PHASE] development
[SECURITY-FOCUS] [Critical for auth features - specify JWT, crypto, session requirements]
[SCOPE] [Specific deliverable with clear success criteria]
[HANDOFF-READY] [Specify if this should prepare for security review]
[MANDATORY CONSTRAINTS - ZERO TOLERANCE]
- NO TODO/FIXME/XXX comments - implement fully or don't include
- NO unimplemented!() or todo!() macros - implement fully or remove feature
- Code MUST compile with zero errors
```

#### For Security Reviews:
```
[CONTEXT] JWT Auth Service - [implemented feature]
[PHASE] review
[SECURITY-FOCUS] [Specific security concerns: timing attacks, token leakage, etc.]
[SCOPE] Comprehensive security audit with actionable findings
[PRIORITY] [Critical for auth service - specify areas of highest concern]
```

### Intelligent Workflow Patterns

#### Pattern 1: JWT Feature Development → Security Review
```bash
# 1. Development phase (auto-detects JWT/auth context)
[CONTEXT] JWT Auth Service - implement token refresh endpoint
[PHASE] development  
[SCOPE] Complete /auth/refresh endpoint with secure rotation pattern
[SECURITY-FOCUS] Prevent token replay, timing attacks, race conditions
[HANDOFF-READY] Yes, prepare for security review

# 2. Automatic handoff triggers
# System detects: JWT handling, security-sensitive code, crypto usage
# → Auto-handoff to rust-code-reviewer

# 3. Security review phase
[CONTEXT] JWT refresh endpoint implemented with rotation
[PHASE] review
[SCOPE] Security audit focusing on token rotation, timing attacks, session hijacking
[PRIORITY] Critical - authentication security
```

#### Pattern 2: Architecture Design → Implementation → Performance Review
```bash
# 1. Architecture planning
[CONTEXT] JWT Auth Service - design high-performance session management
[PHASE] development
[SCOPE] Design Redis-backed session store with PostgreSQL persistence
[REQUIREMENT] Handle 1000+ concurrent sessions, sub-100ms response times

# 2. Implementation with performance focus
[CONTEXT] Session architecture approved
[PHASE] development  
[SCOPE] Implement SessionManager with async Redis + PostgreSQL backend
[HANDOFF-READY] Yes, needs performance and security review

# 3. Comprehensive review
[CONTEXT] SessionManager implemented with Redis+PostgreSQL
[PHASE] review
[SCOPE] Performance analysis, memory safety, concurrency correctness
```

### Auto-Detection Intelligence

The system automatically switches agents based on:

1. **Security-sensitive patterns**: JWT, bcrypt, crypto, auth endpoints → `rust-code-reviewer`
2. **Unsafe code blocks**: Raw pointers, transmute, FFI → `rust-code-reviewer`
3. **Implementation requests**: "implement", "create", "build" → `rust-expert`
4. **Complex coordination**: Multi-step, >10k tokens → `context-manager-pro`
5. **Git analysis**: Detects project phase and security-sensitive changes
6. **Async/concurrency patterns**: Performance-critical concurrent code → Review after implementation

### Security-First Patterns for JWT Auth Service

Given our JWT authentication focus, always trigger security review for:
- **Token generation/validation logic**
- **Password hashing and verification**
- **Session management and storage**
- **Rate limiting implementations**
- **Input validation and sanitization**
- **Database query patterns (SQL injection prevention)**
- **Environment variable handling**
- **Error handling (information leakage prevention)**

### Success Patterns
- **Incremental security-aware development**: Each phase produces secure, testable code
- **Automatic security gates**: No auth code bypasses security review
- **Git-verified implementations**: All claims verified against actual commits
- **Context preservation**: Seamless handoffs maintain security requirements and architectural decisions
- **Teaching-oriented**: Explanations include security implications and "why" behind decisions
- **Performance-aware**: JWT validation must be sub-millisecond, session lookup optimized

### Anti-Patterns to Avoid
- **Security shortcuts**: Never skip security review for "simple" auth changes
- **Manual agent coordination**: Let the system auto-detect optimal workflow
- **Context loss during handoffs**: Use proper handoff system to preserve security requirements
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

# Security-specific tools for JWT auth
cargo audit                          # Dependency vulnerability scanning
cargo deny check                     # License and security policy enforcement
```

**WARNING**: Always verify implementation claims against git commits. When documentation conflicts with git history: **Git history wins**.

## ⚠️ ENFORCEMENT MECHANISMS (MANDATORY)

### 🚨 Automatic Rejection Criteria
The following will cause **AUTOMATIC REJECTION** of any code:

```bash
# These checks run automatically on EVERY commit attempt
# ANY violation = commit BLOCKED

✗ ANY occurrence of "TODO", "FIXME", "XXX" in code
✗ ANY occurrence of unimplemented!() or todo!() macros
✗ ANY compilation errors
✗ Excessive warnings (>30)
✗ Security violations flagged by cargo audit
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
# - Hardcoded secrets or keys
```

### ✅ Required Verification Before ANY Work
```bash
# Run BEFORE starting work:
./scripts/claude-compliance-check.sh

# Run AFTER making changes:
./scripts/claude-compliance-check.sh

# Enhanced checks for JWT auth service:
grep -r "TODO\|FIXME" src/ --include="*.rs" | wc -l              # Must be 0
grep -r "unimplemented!\|todo!" src/ --include="*.rs" | wc -l    # Must be 0
cargo check 2>&1 | grep -c "^error"                              # Must be 0
cargo audit --json | jq '.vulnerabilities | length'             # Must be 0
grep -r "password.*=\|secret.*=\|key.*=" src/ --include="*.rs"   # Must be 0 (no hardcoded secrets)
```

### 📝 Required Agent Instructions
When using ANY agent (rust-expert, rust-code-reviewer, context-manager-pro), **ALWAYS** include:
```
[MANDATORY CONSTRAINTS - ZERO TOLERANCE]
- NO TODO/FIXME/XXX comments - implement fully or don't include
- NO unimplemented!() or todo!() macros - implement fully or remove feature
- NO hardcoded secrets, passwords, or keys
- Code MUST compile with zero errors and zero security warnings
- If you cannot implement something fully, REMOVE IT ENTIRELY
- These are HARD REQUIREMENTS, not guidelines
[SECURITY REQUIREMENTS - JWT AUTH SERVICE]
- All authentication code MUST be reviewed by rust-code-reviewer
- Use constant-time comparison for all secret/token comparisons
- Implement proper input validation and sanitization
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
3. **DON'T** hardcode any secrets or keys
4. **DO** one of these:
   - Implement a minimal working version
   - Return a secure default
   - Remove the feature entirely
   - Throw a proper error with explanation (no information leakage)

**Example of what to do:**
```rust
// ❌ NEVER DO THIS:
fn validate_jwt_token(token: &str) -> Result<Claims> {
    todo!("Implement JWT validation later")  // VIOLATION!
}

// ✅ DO THIS INSTEAD:
fn validate_jwt_token(token: &str) -> Result<Claims> {
    // Return secure error - no implementation details leaked
    Err(AuthError::ValidationUnavailable)
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
- Planning documents
- Code reviews
- Architecture documentation
- Security assessments
- Meeting notes
- Status reports
- Technical specifications

**Rationale**: Precise timestamps enable better tracking of document evolution and decision timing.

## Architecture

### Core Components (from `Documentation/technical/jwt_auth_microservice_specs.md`)
- **Token Manager**: JWT generation/validation (RS256)
- **User Store**: PostgreSQL for credentials/sessions
- **Session Manager**: Refresh token lifecycle with rotation
- **Security Layer**: Rate limiting, bcrypt hashing, input validation

### Key APIs to Implement (Security-Critical)
- `POST /auth/login` - Authentication and token generation
- `POST /auth/refresh` - Token refresh with rotation
- `GET /auth/validate` - Token validation for other services
- `POST /users/register` - User registration with validation
- `POST /auth/logout` - Token invalidation and cleanup

### Database Schema (Security-Focused)
- **PostgreSQL**: `users`, `sessions`, `roles`, `permissions` tables with proper indexing
- **Redis**: Token blacklisting, rate limiting, and session caching
- **Security**: All PII encrypted at rest, audit logging enabled

## Security Configuration

### JWT Tokens (Production-Ready)
- **Access**: RS256, 15-60min TTL, includes user/role context, proper audience validation
- **Refresh**: 7-30 day TTL, single-use rotation pattern, secure storage

### Environment Variables (Security-First)
```bash
# RSA key pair (NEVER commit these to git)
JWT_PRIVATE_KEY_PATH=/secure/keys/jwt_private.pem
JWT_PUBLIC_KEY_PATH=/secure/keys/jwt_public.pem

# Token configuration
JWT_ACCESS_TOKEN_TTL=3600           # 1 hour
JWT_REFRESH_TOKEN_TTL=604800        # 7 days
JWT_ISSUER=jwt-auth-service
JWT_AUDIENCE=api.company.com

# Database connections (use connection pooling)
DATABASE_URL=postgresql://user:pass@localhost:5432/jwt_auth
REDIS_URL=redis://localhost:6379/0

# Security settings
BCRYPT_COST_FACTOR=12               # Adjust based on security/performance needs
RATE_LIMIT_REDIS_URL=redis://localhost:6379/1

# Monitoring and logging
LOG_LEVEL=info
AUDIT_LOG_ENABLED=true
METRICS_ENABLED=true
```

### Rate Limits (DoS Protection)
- **Login**: 5 attempts per IP per 5 minutes
- **Token validation**: 1000 per IP per minute
- **Password reset**: 3 per email per hour
- **Registration**: 10 per IP per hour

### Security Headers and CORS
- Proper CORS configuration for production domains
- Security headers (HSTS, CSP, X-Frame-Options)
- Request/response logging for audit trails

## Current State

**Implementation**: Basic Cargo.toml (Rust 2024), placeholder main.rs
**Dependencies Needed**: 
- **Core**: tokio, axum, serde, uuid, chrono
- **JWT**: jsonwebtoken, ring (for crypto)
- **Hashing**: bcrypt, argon2 (consider for future)
- **Database**: sqlx, redis
- **Security**: secrecy, zeroize (for secure memory handling)
- **Monitoring**: tracing, metrics
- **Testing**: tokio-test, wiremock, proptest

**Next Priority**: Implement core JWT token management with rust-expert, then immediate security review with rust-code-reviewer.
