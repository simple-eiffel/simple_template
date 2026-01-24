# INNOVATIONS: simple_template


**Date**: 2026-01-18

## Date: 2026-01-18

## Innovation Summary

| ID | Innovation | Type | Novelty | Value |
|----|------------|------|---------|-------|
| I-001 | Only Mustache for Eiffel | APPROACH | HIGH | HIGH |
| I-002 | Design by Contract Templates | EIFFEL | HIGH | HIGH |
| I-003 | SCOOP-Safe Template Engine | DESIGN | HIGH | MEDIUM |
| I-004 | Dual API (Full + Quick) | UX | MEDIUM | HIGH |
| I-005 | Configurable Missing Variable Policy | FEATURE | MEDIUM | MEDIUM |

## Value Proposition

**For** Eiffel developers **who need** to generate dynamic text/HTML safely, **simple_template** provides a Mustache-compatible template engine with Design by Contract guarantees, **unlike** string concatenation or ad-hoc solutions **because** it combines industry-standard templating with Eiffel's correctness guarantees.

## Unique Selling Points

1. **Only Mustache implementation for Eiffel** - No alternative exists
2. **Contract-protected API** - Preconditions prevent misuse, postconditions guarantee results
3. **SCOOP-compatible** - Safe for concurrent Eiffel applications
4. **Secure by default** - HTML escaping ON, explicit opt-out required
5. **Two-tier API** - Quick one-liners for simple cases, full API for complex needs

---

## Key Innovations

### I-001: Only Mustache Implementation for Eiffel

**Type**: APPROACH

**Description**: simple_template is the only Mustache-compatible template engine available for the Eiffel programming language.

**Problem Solved**: Eiffel developers previously had no standard templating solution. They either concatenated strings (error-prone, XSS-vulnerable) or built custom solutions (reinventing the wheel).

**Novelty Assessment**:
- New to world: NO (Mustache exists in 40+ languages)
- New to Eiffel: YES
- New to Simple ecosystem: YES

**Evidence of Novelty**:
- Searched EiffelHub, GOBO, ISE libraries - no Mustache implementation found
- Landscape analysis (STEP-2) confirmed gap

**Value**: Brings industry-standard templating to Eiffel ecosystem, enabling:
- Portable template knowledge (Mustache syntax universal)
- Security best practices (auto-escaping)
- Separation of concerns (logic-less templates)

**Risks**:
- Maintaining spec compliance as Mustache evolves
- Mitigation: Track mustache/spec releases, run spec tests

---

### I-002: Design by Contract Templates

**Type**: EIFFEL

**Eiffel Feature Used**: Design by Contract (require/ensure/invariant)

**Description**: Template operations protected by formal contracts that catch errors at call site rather than deep in rendering.

**Innovation**: Most template engines fail silently or throw runtime exceptions. simple_template uses contracts to:
- Prevent invalid state (non-void preconditions)
- Guarantee results (postconditions on render)
- Maintain invariants (tables always initialized)

**Contract Examples**:
```eiffel
set_variable (a_name, a_value: STRING)
  require
    name_not_void: a_name /= Void
    name_not_empty: not a_name.is_empty
    value_not_void: a_value /= Void
  ensure
    variable_set: variables.has (a_name)
    value_stored: variables.item (a_name) ~ a_value
```

**Not Possible In**:
- JavaScript (no native contracts)
- Python (assertions optional, no postconditions)
- Ruby (no contract system)

**Benefit**: Bugs caught at API boundary, not during rendering. Clear documentation of expectations. Formal verification possible.

**Validation**:
- Novel: HIGH - No other Mustache implementation has DBC
- Valuable: HIGH - Catches bugs earlier
- Achievable: HIGH - Already implemented

---

### I-003: SCOOP-Safe Template Engine

**Type**: DESIGN

**Description**: Template engine designed for safe concurrent access in SCOOP (Simple Concurrent Object-Oriented Programming).

**Standard Design**: Most template engines assume single-threaded access or use locks.

**Our Design**:
- No shared mutable state between renders
- Context tables created fresh per render
- No global caches (deferred decision)
- Command/query separation enables SCOOP reasoning

**Eiffel-Specific Advantage**: SCOOP's type system enforces safe concurrent access. Template objects can be passed between SCOOP regions.

**Benefit**: Eiffel web servers can render templates concurrently without race conditions.

**Validation**:
- Novel: HIGH - No other template engine designed for SCOOP
- Valuable: MEDIUM - Important for web servers, less for scripts
- Achievable: HIGH - Already implemented with SCOOP concurrency in ECF

---

### I-004: Dual API (Full + Quick)

**Type**: UX

**Description**: Two-tier API serving different user needs:
- `SIMPLE_TEMPLATE`: Full-featured, configurable
- `SIMPLE_TEMPLATE_QUICK`: Zero-config one-liners

**Problem Solved**: Template engines often force users to choose between simplicity and power. Beginners get lost in configuration; experts feel constrained by simple APIs.

**Not Found In**:
- mustache.js: Single API, must instantiate Mustache object
- Handlebars: Single API, compilation required
- Jinja2: Single API, Environment setup needed

**Our Implementation**:
```eiffel
-- Quick: One line, zero config
result := {SIMPLE_TEMPLATE_QUICK}.render ("Hello {{name}}", vars)

-- Full: Complete control
create template.make_from_string ("Hello {{name}}")
template.set_escape_html (False)
template.set_variable ("name", "World")
result := template.render
```

**Value**:
- Beginners productive immediately
- Experts get full control
- Clear migration path from Quick to Full

**Validation**:
- Novel: MEDIUM - Some libraries have convenience wrappers
- Valuable: HIGH - Reduces friction for simple cases
- Achievable: HIGH - Already implemented

---

### I-005: Configurable Missing Variable Policy

**Type**: FEATURE

**Description**: Three policies for handling undefined variables:
1. `Policy_empty_string`: Return "" (default, safe)
2. `Policy_keep_placeholder`: Return "{{name}}" (debugging)
3. `Policy_raise_exception`: Set error state (strict)

**Not Found In**:
- mustache.js: Always returns empty string
- Handlebars: Always returns empty string (unless strict mode enabled separately)
- Jinja2: Raises exception by default

**Our Implementation**:
```eiffel
template.set_missing_variable_policy (Policy_keep_placeholder)
-- Now {{undefined}} renders as "{{undefined}}" instead of ""
```

**Value**:
- Safe default (empty string prevents info leakage)
- Debugging mode (keep placeholder shows what's missing)
- Strict mode (fail fast for required variables)

**Validation**:
- Novel: MEDIUM - Handlebars has strict mode, but not this flexibility
- Valuable: MEDIUM - Helps debugging, not critical
- Achievable: HIGH - Already implemented

---

## Differentiation from Alternatives

| Aspect | mustache.js | Handlebars | simple_template |
|--------|-------------|------------|-----------------|
| Language | JavaScript | JavaScript | **Eiffel** |
| Contracts | None | None | **Full DBC** |
| Concurrency | Single-thread | Single-thread | **SCOOP-safe** |
| Missing vars | Empty only | Empty/strict | **3 policies** |
| API tiers | Single | Single | **Dual (Full+Quick)** |
| Compilation | No | Yes | No (future option) |
| Lambdas | Yes | Yes | No (deliberate) |
| Escaping default | Yes | Yes | Yes |

## Eiffel Advantages

| Eiffel Feature | How We Use It | Benefit |
|----------------|---------------|---------|
| Design by Contract | Pre/post on all public features | Early bug detection |
| Void Safety | All references checked | No null pointer crashes |
| SCOOP | Concurrent rendering safe | Web server scalability |
| Once functions | Singleton logger | Efficient resource use |
| Command/Query | Queries don't modify state | Reasoning about code |
| Invariants | Tables always non-void | Consistent internal state |

## Innovation Risks

| Innovation | Risk | Mitigation |
|------------|------|------------|
| I-001 (Only Mustache) | No competition drives complacency | Track spec updates, user feedback |
| I-002 (DBC) | Contracts add overhead | Assertions configurable per build |
| I-003 (SCOOP) | Limited testing in concurrent scenarios | Add SCOOP stress tests |
| I-004 (Dual API) | Two APIs to maintain | Quick delegates to Full internally |
| I-005 (Policies) | Users confused by options | Clear defaults, good docs |

## Innovation Viability

| Innovation | Novel | Valuable | Achievable | Viable |
|------------|-------|----------|------------|--------|
| I-001 | HIGH | HIGH | HIGH | ✓ |
| I-002 | HIGH | HIGH | HIGH | ✓ |
| I-003 | HIGH | MEDIUM | HIGH | ✓ |
| I-004 | MEDIUM | HIGH | HIGH | ✓ |
| I-005 | MEDIUM | MEDIUM | HIGH | ✓ |

## Competitive Moat

**Why can't others copy**:
- Eiffel-specific (DBC, SCOOP) not portable to other languages
- Only Eiffel Mustache implementation creates ecosystem lock-in
- Integration with simple_* ecosystem adds switching cost

**How long advantage lasts**:
- Indefinitely for Eiffel users (no alternative)
- As long as simple_* ecosystem grows

**How to extend advantage**:
- Run official Mustache spec tests for compliance credibility
- Add more simple_* integrations (simple_http templates, etc.)
- Performance optimization for web server use cases
