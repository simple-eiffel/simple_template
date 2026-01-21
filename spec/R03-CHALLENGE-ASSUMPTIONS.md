# ASSUMPTION CHALLENGE REPORT: simple_template

## Date: 2026-01-18
## Source: R01-PARSED-RESEARCH.md, R02-DOMAIN-ANALYSIS.md

---

## Summary

| Metric | Count |
|--------|-------|
| Assumptions challenged | 12 |
| Invalid assumptions found | 1 |
| Questionable assumptions | 3 |
| Requirements questioned | 19 |
| Requirements changed | 2 |
| Missing requirements found | 5 |
| Decisions to reconsider | 1 |
| Missing risks found | 2 |

---

## Assumption Extraction

### About Users
| ID | Assumption | Evidence | Status |
|----|------------|----------|--------|
| A-001 | Users want Mustache compatibility | Industry standard | VALID |
| A-002 | Users prioritize security over flexibility | OWASP guidelines | VALID |
| A-003 | Beginners need one-liner API | Common pattern in libraries | VALID |
| A-004 | Users won't need lambdas | Rarely used in practice | QUESTIONABLE |

### About Technology
| ID | Assumption | Evidence | Status |
|----|------------|----------|--------|
| A-005 | SCOOP is the concurrency model | simple_* standard | VALID |
| A-006 | STRING is sufficient for all values | Mustache is text-based | VALID |
| A-007 | Templates are < 1MB typically | No evidence | QUESTIONABLE |
| A-008 | UTF-8 encoding is sufficient | Modern standard | VALID |

### About Requirements
| ID | Assumption | Evidence | Status |
|----|------------|----------|--------|
| A-009 | HTML escaping covers all XSS | OWASP says NO | INVALID |
| A-010 | Missing variables should be silent | Mustache default | VALID |
| A-011 | 100 levels is enough depth | No evidence | QUESTIONABLE |
| A-012 | Performance < 100ms is acceptable | No user input | VALID (reasonable) |

---

## Assumption Challenges

### CHALLENGE: A-004 (Users won't need lambdas)

**Assumption**: Lambda support is rarely needed and can be excluded.

**Questions**:
- Is this always true? **NO** - Some advanced users may want lambdas
- What if it's false? Users must pre-process data or use different approach
- How would we know? User feature requests

**Verdict**: QUESTIONABLE
**Action**: KEEP exclusion but document workaround (pre-process data)

---

### CHALLENGE: A-007 (Templates < 1MB)

**Assumption**: Templates are typically small (< 1MB).

**Questions**:
- Is this always true? **UNKNOWN** - No usage data
- What if it's false? Performance issues, memory problems
- How would we know? Stress testing

**Verdict**: QUESTIONABLE
**Action**: Add stress tests, document any limits discovered

---

### CHALLENGE: A-009 (HTML escaping covers all XSS)

**Assumption**: HTML entity escaping (`& < > " '`) prevents XSS.

**Questions**:
- Is this always true? **NO** - Only protects HTML body context
- What if it's false? XSS in JavaScript/URL contexts
- How would we know? Security testing

**Verdict**: INVALID
**Action**:
1. Document that escaping is HTML-body only
2. Add warning against use in script/href contexts
3. Consider adding FR for context-aware escaping (future)

---

### CHALLENGE: A-011 (100 levels depth is enough)

**Assumption**: Max partial depth of 100 is sufficient.

**Questions**:
- Is this always true? **YES** - 100 is extremely deep
- What if it's false? Legitimate use case blocked
- How would we know? User complaint

**Verdict**: QUESTIONABLE but acceptable
**Action**: KEEP 100 as default, make configurable if requested

---

## Requirement Necessity

### FR-001 to FR-010 (MUST requirements)

| ID | Requirement | Challenge Result | Verdict |
|----|-------------|------------------|---------|
| FR-001 | Variable interpolation | Core functionality, cannot cut | KEEP |
| FR-002 | HTML escaping default | Security requirement | KEEP |
| FR-003 | Raw output | Necessary for trusted HTML | KEEP |
| FR-004 | Section rendering | Core Mustache feature | KEEP |
| FR-005 | Inverted sections | Core Mustache feature | KEEP |
| FR-006 | Comment removal | Core Mustache feature | KEEP |
| FR-007 | Partial inclusion | Core Mustache feature | KEEP |
| FR-008 | List iteration | Core Mustache feature | KEEP |
| FR-009 | Missing variable policy | Good flexibility | KEEP |
| FR-010 | Context lookup chain | Core Mustache behavior | KEEP |

### FR-011 to FR-015 (SHOULD requirements)

| ID | Requirement | Challenge | Verdict |
|----|-------------|-----------|---------|
| FR-011 | File-based templates | Convenience, not essential | KEEP as SHOULD |
| FR-012 | Nested sections | Already works, just depth limit | KEEP |
| FR-013 | Dotted name access | Mustache spec feature | **UPGRADE to MUST** |
| FR-014 | Bulk variable setting | Convenience only | KEEP as SHOULD |
| FR-015 | Template validation | Useful for debugging | KEEP as SHOULD |

### FR-016 to FR-018 (COULD requirements)

| ID | Requirement | Challenge | Verdict |
|----|-------------|-----------|---------|
| FR-016 | Template caching | Premature optimization? | KEEP as COULD |
| FR-017 | Render to file | Convenience only | KEEP as COULD |
| FR-018 | Required variables query | Nice for tooling | KEEP as COULD |

### FR-019 (Defensive requirement)

| ID | Requirement | Challenge | Verdict |
|----|-------------|-----------|---------|
| FR-019 | Circular partial detection | Critical safety | KEEP as MUST |

---

## Requirement Changes

### Upgraded

| ID | Original | New | Reason |
|----|----------|-----|--------|
| FR-013 | SHOULD | MUST | Dotted names are in Mustache core spec, not optional |

### Downgraded

None.

### Removed

None.

---

## Missing Requirements (Completeness Check)

### Error Handling

**FR-NEW-001: Error reporting mechanism**
- What happens when template parsing fails?
- How does user know what went wrong?
- **Requirement**: `last_error: detachable STRING` query after failed operation
- **Priority**: SHOULD
- **Rationale**: Debugging support

**FR-NEW-002: Graceful handling of malformed tags**
- What if `{{#section}}` has no matching `{{/section}}`?
- **Requirement**: Treat as literal text, set `last_error`
- **Priority**: SHOULD
- **Rationale**: NFR-R-001 requires 0% crash rate

### Edge Cases

**FR-NEW-003: Empty template handling**
- What does `render("")` return?
- **Requirement**: Return empty string, no error
- **Priority**: MUST (implicit but should be explicit)
- **Rationale**: Basic edge case

**FR-NEW-004: Whitespace handling in tags**
- Does `{{ name }}` (with spaces) work?
- **Requirement**: Trim whitespace inside tags
- **Priority**: MUST (Mustache spec requires this)
- **Rationale**: Spec compliance

### Security

**FR-NEW-005: Document security limitations**
- **Requirement**: README must document that escaping is HTML-body only
- **Priority**: MUST (from A-009 finding)
- **Rationale**: User safety

---

## Decision Challenges

### D-BUILD-BUY: Continue with existing

**Challenge**: Was this the right choice?
- Alternatives fairly evaluated? YES - No Eiffel alternative exists
- Long-term implications? Maintenance burden on single codebase
- Still valid? YES

**Verdict**: AFFIRM

---

### D-ARCH-001: Facade pattern

**Challenge**: Was this the right choice?
- Alternatives fairly evaluated? YES - Component pattern rejected for complexity
- Long-term implications? Limited extensibility
- Still valid? YES - Matches simple_* philosophy

**Verdict**: AFFIRM

---

### D-ARCH-002: Two-class API

**Challenge**: Was this the right choice?
- Alternatives fairly evaluated? YES
- Long-term implications? Two APIs to maintain
- Still valid? YES - Clear separation of concerns

**Verdict**: AFFIRM

---

### D-FEAT-001: Exclude lambdas

**Challenge**: Was this the right choice?
- Alternatives fairly evaluated? YES - Complexity vs value assessed
- Long-term implications? Cannot claim full Mustache compliance
- Still valid? MOSTLY - Monitor user feedback

**Verdict**: AFFIRM with monitoring

---

### D-FEAT-002: Exclude set delimiter

**Challenge**: Was this the right choice?
- Alternatives fairly evaluated? YES - Rare use case
- Long-term implications? Cannot use in TeX contexts
- Still valid? YES

**Verdict**: AFFIRM

---

### D-TRADE-002: Security over flexibility

**Challenge**: Was this the right choice?
- Is escape-by-default actually safer? YES per OWASP
- Does it frustrate users? Some, but explicit opt-out is clear

**Verdict**: AFFIRM

---

### D-TECH-002: No generics in public API

**Challenge**: Was this the right choice?
- Alternatives fairly evaluated? Partially
- Long-term implications? Users must convert all values to STRING
- Still valid? QUESTIONABLE

**Concern**: Forcing STRING conversion is tedious. Could accept ANY and call `out`.

**Verdict**: RECONSIDER
**Recommendation**: Consider `set_variable (name: STRING; value: ANY)` that calls `value.out`

---

## Scope Challenge

### Scope Too Large?

**Features that could be cut:**
- FR-017 (render_to_file): User can write string to file themselves
- FR-018 (required_variables): Nice but not essential

**Impact**: Minor convenience loss, simpler codebase

**Recommendation**: Keep as COULD, don't prioritize

### Scope Too Small?

**Features that should be added:**
- FR-NEW-004 (whitespace handling): Actually required by spec
- Context-aware escaping: Would prevent XSS in more contexts

**Impact**: Better spec compliance, better security

**Recommendation**: Add FR-NEW-004 as MUST, context-aware escaping as future COULD

### Scope Verdict

**Current scope**: ABOUT RIGHT
- Core Mustache features covered
- Appropriate exclusions (lambdas, set delimiter)
- Good balance of simplicity vs features

**Recommended changes**:
1. Add FR-NEW-001 through FR-NEW-005
2. Upgrade FR-013 to MUST
3. Reconsider D-TECH-002 (ANY values)

---

## Risk Challenges

### Missing Risks

**RISK-NEW-001: Regex Denial of Service (ReDoS)**
- If template parsing uses regex, pathological input could hang
- **Mitigation**: Review parsing code for regex usage, use non-backtracking patterns
- **Severity**: MEDIUM

**RISK-NEW-002: Memory exhaustion from large lists**
- Very large list could exhaust memory during iteration
- **Mitigation**: Document size recommendations, consider streaming for Phase 2
- **Severity**: LOW

### Overblown Risks

**RISK-005 (DBC overhead)**: Listed as MODERATE
- **Reassessment**: Standard Eiffel practice, configurable per build
- **Downgrade to**: LOW (non-issue with proper build config)

### Underestimated Risks

None identified.

---

## Domain Model Challenges

### CONCEPT: CONTEXT

**Challenge**: Should Context be a separate class or just HASH_TABLEs?
- Current model: CONTEXT as conceptual grouping of tables
- Alternative: Just use HASH_TABLEs directly on TEMPLATE
- **Verdict**: KEEP - Context concept useful for documentation and parent chain

### CONCEPT: RENDERER

**Challenge**: Should Renderer be exposed or internal?
- Current model: Internal implementation detail
- Alternative: Expose for customization
- **Verdict**: KEEP internal - Matches facade pattern decision

### CONCEPT: ESCAPER

**Challenge**: Is a separate Escaper concept needed?
- Current model: Escaper as separate stateless component
- Alternative: Just a helper function inside renderer
- **Verdict**: CHANGE to helper - No need for separate class, just `escape_html` feature

### RELATIONSHIP: QUICK HAS-A TEMPLATE

**Challenge**: Is this the right relationship?
- Current model: Quick wraps Template
- Alternative: Quick inherits from Template
- **Verdict**: KEEP HAS-A - Different API signatures prevent IS-A

---

## Eiffel-Specific Challenges

### Void Safety

**Can everything be non-void?**
- Template source: YES (empty string is valid)
- Variables table: YES (empty table is valid)
- Render result: YES (empty string is valid)
- Last error: NO - must be detachable (only set on error)

**What must be detachable?**
- `last_error: detachable STRING`
- Parent context (optional): `parent: detachable like Current`

### SCOOP Compatibility

**Any shared mutable state?**
- Variables/sections/lists tables are per-instance: SAFE
- No global state: SAFE
- Logger is once-per-thread: SAFE

**Any thread-unsafe patterns?**
- None identified

**Verdict**: SCOOP COMPATIBLE

### Contract Feasibility

**Can requirements be expressed as contracts?**

| Requirement | Contract | Feasible |
|-------------|----------|----------|
| FR-001 | Postcondition: Result.has_substring(value) | YES |
| FR-002 | Postcondition: not Result.has('<') if escaping | YES |
| FR-009 | Postcondition per policy | YES |
| NFR-P-001 | Performance < 100ms | NO (not contractable) |
| NFR-R-001 | No crashes | NO (implicit) |

**Unverifiable via contracts:**
- Performance requirements (test via benchmarks)
- Crash prevention (test via fuzzing)

### Library Compatibility

**Available simple_* libraries:**
- simple_logger: Used for logging - COMPATIBLE
- simple_testing: Used for tests - COMPATIBLE
- simple_file: Could use for file I/O - NOT CURRENTLY USED
- simple_string: Could use for string utils - NOT CURRENTLY USED

**Any conflicts?**
- None identified

---

## Final Requirements (Revised)

### MUST (12)
| ID | Requirement |
|----|-------------|
| FR-001 | Variable interpolation |
| FR-002 | HTML escaping by default |
| FR-003 | Raw/unescaped output |
| FR-004 | Section rendering |
| FR-005 | Inverted sections |
| FR-006 | Comment removal |
| FR-007 | Partial inclusion |
| FR-008 | List iteration |
| FR-009 | Missing variable policy |
| FR-010 | Context lookup chain |
| FR-013 | Dotted name access (**UPGRADED**) |
| FR-019 | Circular partial detection |
| FR-NEW-003 | Empty template returns empty string |
| FR-NEW-004 | Whitespace trimming in tags |
| FR-NEW-005 | Document security limitations |

### SHOULD (6)
| ID | Requirement |
|----|-------------|
| FR-011 | File-based templates |
| FR-012 | Nested sections (3+ levels) |
| FR-014 | Bulk variable setting |
| FR-015 | Template validation |
| FR-NEW-001 | Error reporting (`last_error`) |
| FR-NEW-002 | Graceful malformed tag handling |

### COULD (3)
| ID | Requirement |
|----|-------------|
| FR-016 | Template caching |
| FR-017 | Render to file |
| FR-018 | Required variables query |

---

## Decisions to Reconsider

| ID | Decision | Concern | Recommendation |
|----|----------|---------|----------------|
| D-TECH-002 | No generics, STRING only | User must convert all values | Consider `set_variable(name: STRING; value: ANY)` using `value.out` |

---

## Eiffel Considerations for Design Phase

1. **Detachable attributes**: Only `last_error` and `parent` context need detachable
2. **SCOOP**: Design is already SCOOP-safe, no changes needed
3. **Contracts**: All functional requirements can have contracts except performance
4. **Escaper**: Merge into renderer as helper feature, not separate class
5. **ANY values**: Consider accepting ANY and calling `.out` for convenience

---

## Ready For: R04-CLASS-DESIGN

Analysis phase complete. All assumptions challenged, requirements validated/revised, decisions affirmed/flagged. Ready to proceed with class design.
