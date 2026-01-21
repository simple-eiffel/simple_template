# RISK ANALYSIS: simple_template

## Date: 2026-01-18

## Risk Summary

| Level | Count | Examples |
|-------|-------|----------|
| Critical | 1 | R-TECH-001 |
| Major | 3 | R-TECH-002, R-TECH-003, R-SEC-001 |
| Moderate | 4 | R-SCOPE-001, R-EXT-001, R-INNOV-001, R-INNOV-002 |
| Minor | 2 | R-RES-001, R-SCHED-001 |

**Overall Risk Level**: LOW-MEDIUM
**Proceed Recommendation**: YES - Library already exists and works; focus on hardening

## Risk Matrix

```
                    IMPACT
               LOW     MEDIUM    HIGH
          ┌─────────┬─────────┬─────────┐
     HIGH │         │         │ R-TECH-001│
          ├─────────┼─────────┼─────────┤
L    MED  │R-RES-001│R-SCOPE-001│R-SEC-001│
          │         │R-INNOV-001│R-TECH-002│
          ├─────────┼─────────┼─────────┤
     LOW  │R-SCHED-001│R-EXT-001│R-TECH-003│
          │         │R-INNOV-002│         │
          └─────────┴─────────┴─────────┘
```

---

## Critical Risks

### R-TECH-001: Circular Partial Infinite Loop

| Aspect | Assessment |
|--------|------------|
| Category | TECHNICAL |
| Likelihood | HIGH |
| Impact | HIGH |
| Score | 9 (Critical) |

**Description**: If a partial includes itself (directly or through a chain), rendering will loop infinitely, hanging the application.

**Trigger**: User creates partials A→B→A or A→A.

**Early Warning Signs**:
- Render takes unusually long
- Memory consumption grows
- Stack overflow errors

**Mitigation**:
- **Prevention**: Add depth counter, fail at max depth (e.g., 100)
- **Contingency**: Document limitation, warn users
- **Chosen**: Prevention - add depth limit with clear error message

**Contingency Plan**:
1. If detected in production: User reports hang
2. Immediate: Add depth counter to render_partial
3. Recovery: Release patch version

**Owner**: Maintainer
**Status**: IDENTIFIED - needs implementation

---

## Major Risks

### R-TECH-002: XSS via Non-HTML Contexts

| Aspect | Assessment |
|--------|------------|
| Category | TECHNICAL |
| Likelihood | MEDIUM |
| Impact | HIGH |
| Score | 6 (Major) |

**Description**: HTML escaping doesn't protect against XSS in JavaScript contexts, URL attributes, or CSS. User might assume template is "safe" and use in unsafe contexts.

**Trigger**: User puts `{{userInput}}` inside `<script>` or `href="javascript:{{x}}"`.

**Mitigation**:
- **Prevention**: Cannot prevent misuse; escaping is HTML-body only
- **Contingency**: Clear documentation that escaping is for HTML body ONLY
- **Chosen**: Document limitations prominently

**Owner**: Maintainer (documentation)
**Status**: IDENTIFIED - needs documentation update

---

### R-TECH-003: Very Large Template Performance

| Aspect | Assessment |
|--------|------------|
| Category | TECHNICAL |
| Likelihood | LOW |
| Impact | HIGH |
| Score | 3 (Major) |

**Description**: No performance testing done with very large templates (>100KB) or many variables (>10,000). Could have O(n²) or worse behavior.

**Trigger**: User loads large template or massive context.

**Mitigation**:
- **Prevention**: Stress testing in maintenance phase
- **Contingency**: Document size limits if found
- **Chosen**: Add stress tests, document any limits discovered

**Owner**: Maintainer
**Status**: IDENTIFIED - pending stress testing

---

### R-SEC-001: Security Bypass via Raw Output

| Aspect | Assessment |
|--------|------------|
| Category | SECURITY |
| Likelihood | MEDIUM |
| Impact | HIGH |
| Score | 6 (Major) |

**Description**: Users might use `{{{raw}}}` or `set_escape_html(False)` without understanding XSS implications, creating vulnerabilities.

**Trigger**: Developer uses raw output with user-controlled data.

**Mitigation**:
- **Prevention**: Cannot prevent; raw output is legitimate feature
- **Contingency**: Strong documentation warnings, code comments
- **Chosen**: Document with security warnings, examples of safe vs unsafe usage

**Owner**: Maintainer (documentation)
**Status**: IDENTIFIED - needs documentation update

---

## Moderate Risks

### R-SCOPE-001: Feature Creep (Lambda Requests)

| Aspect | Assessment |
|--------|------------|
| Category | SCOPE |
| Likelihood | MEDIUM |
| Impact | MEDIUM |
| Score | 4 (Moderate) |

**Description**: Users may request lambda support or other excluded features, pressuring scope expansion.

**Trigger**: User requests "full Mustache compliance."

**Mitigation**:
- **Prevention**: Document exclusions with rationale upfront
- **Contingency**: Maintain "won't implement" list with reasons
- **Chosen**: Clear documentation of scope boundaries

**Owner**: Maintainer
**Status**: MITIGATING - documented in DECISIONS

---

### R-EXT-001: Mustache Spec Changes

| Aspect | Assessment |
|--------|------------|
| Category | EXTERNAL |
| Likelihood | LOW |
| Impact | MEDIUM |
| Score | 2 (Moderate) |

**Description**: Mustache spec could change in ways that require significant rework.

**Trigger**: New Mustache spec version with breaking changes.

**Mitigation**:
- **Prevention**: Monitor mustache/spec repository
- **Contingency**: Version-lock compatibility claims (e.g., "compatible with Mustache 1.4")
- **Chosen**: Monitor spec, version-lock claims

**Owner**: Maintainer
**Status**: IDENTIFIED

---

### R-INNOV-001: DBC Overhead in Production

| Aspect | Assessment |
|--------|------------|
| Category | INNOVATION |
| Likelihood | MEDIUM |
| Impact | MEDIUM |
| Score | 4 (Moderate) |

**Description**: Design by Contract assertions may add performance overhead in production builds.

**Trigger**: High-volume template rendering with assertions enabled.

**Mitigation**:
- **Prevention**: EiffelStudio allows disabling assertions in release builds
- **Contingency**: Document assertion configuration for production
- **Chosen**: Document recommended production assertion levels

**Owner**: Maintainer
**Status**: MITIGATING - standard Eiffel practice

---

### R-INNOV-002: SCOOP Untested in Real Concurrent Scenarios

| Aspect | Assessment |
|--------|------------|
| Category | INNOVATION |
| Likelihood | LOW |
| Impact | MEDIUM |
| Score | 2 (Moderate) |

**Description**: While designed for SCOOP, no concurrent stress tests exist. Could have subtle race conditions.

**Trigger**: Heavy concurrent template rendering in web server.

**Mitigation**:
- **Prevention**: Add SCOOP stress tests in maintenance-xtreme phase
- **Contingency**: Document as "SCOOP-designed, not stress-tested"
- **Chosen**: Add stress tests

**Owner**: Maintainer
**Status**: IDENTIFIED - pending stress testing

---

## Minor Risks

### R-RES-001: Single Maintainer

| Aspect | Assessment |
|--------|------------|
| Category | RESOURCE |
| Likelihood | MEDIUM |
| Impact | LOW |
| Score | 2 (Minor) |

**Description**: Library has single maintainer. Bus factor = 1.

**Mitigation**: Open source, documented code, simple_* ecosystem visibility.

---

### R-SCHED-001: Spec Test Suite Integration

| Aspect | Assessment |
|--------|------------|
| Category | SCHEDULE |
| Likelihood | LOW |
| Impact | LOW |
| Score | 1 (Minor) |

**Description**: Integrating official Mustache spec tests may take longer than expected.

**Mitigation**: Optional enhancement, not blocking core functionality.

---

## Mitigation Plan

| Risk | Action | When | Owner | Status |
|------|--------|------|-------|--------|
| R-TECH-001 | Add partial depth limit | Maintenance phase | Maintainer | PLANNED |
| R-TECH-002 | Document HTML-only escaping | Documentation update | Maintainer | PLANNED |
| R-TECH-003 | Run stress tests | Maintenance-xtreme | Maintainer | PLANNED |
| R-SEC-001 | Add security warnings to docs | Documentation update | Maintainer | PLANNED |
| R-INNOV-002 | Add SCOOP stress tests | Maintenance-xtreme | Maintainer | PLANNED |

## Contingency Plans

### If R-TECH-001 Occurs (Infinite Loop in Production)

**Trigger**: User reports application hang during template render.

**Immediate Actions**:
1. Identify circular partial chain in user's template
2. Provide workaround: restructure partials
3. Fast-track depth limit implementation

**Escalation**: GitHub issue, priority fix release

**Recovery**: Patch release with depth limit, document in CHANGELOG

### If R-SEC-001 Occurs (XSS via Raw Output)

**Trigger**: Security vulnerability reported.

**Immediate Actions**:
1. Confirm vulnerability is in user code, not library
2. If library issue: assess and patch
3. If user misuse: provide guidance

**Escalation**: Security advisory if library flaw

**Recovery**: Documentation update with prominent warnings

## Monitoring

| Risk | Indicator | Check Frequency | Threshold |
|------|-----------|-----------------|-----------|
| R-TECH-001 | GitHub issues mentioning "hang" or "loop" | Weekly | Any report |
| R-TECH-003 | Performance complaints | Monthly | Multiple reports |
| R-EXT-001 | mustache/spec releases | Monthly | New version |

## Proceed Conditions

Given this is an existing, working library, proceed with:

1. **Immediate**: Document security limitations (R-TECH-002, R-SEC-001)
2. **Maintenance phase**: Add depth limit for partials (R-TECH-001)
3. **Maintenance-xtreme phase**: Stress testing (R-TECH-003, R-INNOV-002)

**No blocking risks identified.** All critical/major risks have clear mitigation paths.
