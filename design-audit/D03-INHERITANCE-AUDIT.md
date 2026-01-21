# INHERITANCE AUDIT: simple_template

## Date: 2026-01-18
## Source: Actual codebase analysis

---

## Summary

| Metric | Count |
|--------|-------|
| Total inheritance relationships | 0 |
| Correct | N/A |
| Questionable | 0 |
| Incorrect | 0 |

---

## Inheritance Analysis

### Production Classes

| Class | Inherits From | Reason |
|-------|---------------|--------|
| SIMPLE_TEMPLATE | ANY (implicit) | Standalone class |
| SIMPLE_TEMPLATE_QUICK | ANY (implicit) | Standalone class |

### Test Classes

| Class | Inherits From | Reason |
|-------|---------------|--------|
| LIB_TESTS | TEST_SET_BASE | Standard test pattern |
| TEST_APP | None explicit | Application root |

---

## Liskov Substitution Principle (LSP)

No custom inheritance relationships to audit.

The design explicitly avoided inheritance between SIMPLE_TEMPLATE and SIMPLE_TEMPLATE_QUICK:

**Decision**: SIMPLE_TEMPLATE_QUICK HAS-A SIMPLE_TEMPLATE (composition)

**Rationale** (from spec):
- Different API signatures prevent IS-A
- Liskov test fails (QUICK cannot substitute for TEMPLATE)
- QUICK is a convenience wrapper, not a template subtype

**VERDICT**: CORRECT DESIGN DECISION

---

## Semantic IS-A Check

### Question: Should SIMPLE_TEMPLATE_QUICK inherit from SIMPLE_TEMPLATE?

**Analysis**:

| Test | Result |
|------|--------|
| Is QUICK truly a kind of TEMPLATE? | NO - Different purpose |
| Can QUICK replace TEMPLATE everywhere? | NO - Different signatures |
| Does QUICK want TEMPLATE's interface? | PARTIAL - Only some features |
| Does QUICK want TEMPLATE's implementation? | YES - Delegates to it |

**Liskov Test**:
- `SIMPLE_TEMPLATE.render: STRING` - returns rendered output
- `SIMPLE_TEMPLATE_QUICK.render (template, vars): STRING` - different signature

Cannot substitute QUICK where TEMPLATE is expected.

**VERDICT**: HAS-A is correct. IS-A would be wrong.

---

## Refused Bequest Check

No inheritance, so no refused bequest possible.

If QUICK had inherited from TEMPLATE, it would have:
- Ignored: set_variable, set_section, set_list, set_escape_html, etc.
- Reason: QUICK wraps these in one-liner calls

This confirms the HAS-A decision was correct.

---

## Implementation-Only Inheritance Check

No inheritance, so no implementation-only inheritance issues.

---

## Multiple Inheritance Audit

No multiple inheritance in this codebase.

---

## Inheritance Depth Audit

| Class | Depth | Chain |
|-------|-------|-------|
| SIMPLE_TEMPLATE | 1 | ANY → SIMPLE_TEMPLATE |
| SIMPLE_TEMPLATE_QUICK | 1 | ANY → SIMPLE_TEMPLATE_QUICK |

**Maximum depth**: 1

**VERDICT**: EXCELLENT - Flat hierarchy is appropriate for this domain.

---

## Composition Analysis

### SIMPLE_TEMPLATE_QUICK → SIMPLE_TEMPLATE

```eiffel
-- QUICK uses TEMPLATE internally (local variables in features)
render (a_template: STRING; a_vars: ...): STRING
  local
    l_tpl: SIMPLE_TEMPLATE  -- Creates fresh instance
  do
    create l_tpl.make_from_string (a_template)
    ...
    Result := l_tpl.render
  end
```

**Pattern**: Creates new SIMPLE_TEMPLATE in each method call.

**Alternative**: Could cache a single instance.

**Trade-off Analysis**:
- Current: Clean, no state between calls, thread-safe
- Alternative: Slight performance gain, requires cleanup between calls

**VERDICT**: Current approach is correct for SCOOP safety and simplicity.

---

## Deferred Class Usage

No deferred classes in this codebase.

**Question**: Should there be a deferred TEMPLATE_ENGINE base?

**Analysis**:
- Only one template engine type (Mustache)
- No need for pluggable engines
- No benefit from abstraction

**VERDICT**: No deferred class needed. YAGNI applies.

---

## Correct Design Decisions

| Decision | Reason | Verdict |
|----------|--------|---------|
| No inheritance between QUICK and TEMPLATE | Different APIs, LSP violation | CORRECT |
| Flat hierarchy | Simple domain, no type hierarchy needed | CORRECT |
| Composition in QUICK | Reuses TEMPLATE without coupling | CORRECT |
| No deferred classes | Single implementation, no extension needed | CORRECT |

---

## Inheritance Smells

**None detected.**

---

## Recommended Changes

**None required.**

The inheritance structure (or lack thereof) is appropriate for this domain.

---

## Alternative Designs Considered

### Alternative 1: QUICK inherits TEMPLATE

```eiffel
class SIMPLE_TEMPLATE_QUICK
inherit
  SIMPLE_TEMPLATE
    rename
      render as template_render
    end
feature
  render (a_template: STRING; a_vars: ...): STRING
    do
      make_from_string (a_template)
      -- set vars
      Result := template_render
    end
```

**Problems**:
- Inherits 40 features, only uses 3
- Liskov violation (different render signature)
- State leakage between calls

**REJECTED**

### Alternative 2: Shared deferred base

```eiffel
deferred class TEMPLATE_RENDERER
feature
  render: STRING deferred end
end

class SIMPLE_TEMPLATE inherit TEMPLATE_RENDERER ...
class SIMPLE_TEMPLATE_QUICK inherit TEMPLATE_RENDERER ...
```

**Problems**:
- Over-engineering for single use case
- Different render signatures won't work
- No polymorphic usage expected

**REJECTED**

---

## Final Assessment

| Aspect | Score | Notes |
|--------|-------|-------|
| LSP Compliance | 10/10 | No violations (no inheritance) |
| Semantic Correctness | 10/10 | HAS-A correctly chosen over IS-A |
| Hierarchy Depth | 10/10 | Optimal (flat) |
| Composition Usage | 10/10 | Appropriate delegation |
| Deferred Usage | 10/10 | Correctly avoided (YAGNI) |

**Overall Inheritance Score: 10/10** (Excellent)

---

## Next Step

→ D04-GENERICITY-SCAN.md
