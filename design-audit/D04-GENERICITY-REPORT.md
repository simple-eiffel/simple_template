# GENERICITY SCAN: simple_template

## Date: 2026-01-18
## Source: Actual codebase analysis

---

## Summary

| Metric | Value |
|--------|-------|
| Generic classes currently | 0 |
| Genericity opportunities found | 0 (major), 1 (minor) |
| Estimated code reduction | 0% |

---

## Duplicate Structure Detection

**Criteria**: Classes with same structure, different types

### Scan Results

| Pattern | Found |
|---------|-------|
| STRING_LIST, INTEGER_LIST parallel classes | NO |
| Type-specific processors | NO |
| Duplicated containers | NO |

**VERDICT**: No duplicate structures found.

The codebase uses standard library generics (HASH_TABLE, ARRAYED_LIST) appropriately.

---

## Parallel Hierarchy Detection

**Criteria**: Type-specific class hierarchies

### Scan Results

No parallel hierarchies found.

Only 2 production classes exist:
- SIMPLE_TEMPLATE (template engine)
- SIMPLE_TEMPLATE_QUICK (convenience wrapper)

These are not type variants - they have different purposes.

**VERDICT**: No parallel hierarchies.

---

## Type-Specific Feature Detection

**Criteria**: Features duplicated for different types

### Scan Results

No type-specific feature patterns found.

All features operate on consistent types:
- Template sources: STRING
- Variable values: STRING
- Sections: BOOLEAN
- Lists: ARRAYED_LIST [HASH_TABLE [STRING, STRING]]

**VERDICT**: No type-specific duplication.

---

## Unconstrained ANY Detection

**Criteria**: Features using ANY where specific type needed

### Scan Results

| Location | Uses ANY | Issue |
|----------|----------|-------|
| SIMPLE_TEMPLATE | No | Clean |
| SIMPLE_TEMPLATE_QUICK | No | Clean |

**VERDICT**: No ANY usage. All types are specific.

---

## Type Casting Detection

**Criteria**: Code that casts or checks types

### Scan Results

```eiffel
-- In render_template:
if attached partials.item (l_var_name) as l_partial then

-- In render_section:
if attached l_list as ll then

-- In is_section_truthy:
if attached lists.item (a_name) as ll then
```

These are **void-safety checks**, not type casts.

| Pattern | Count | Reason | Issue |
|---------|-------|--------|-------|
| `attached X as Y` | 4 | Void-safe access | OK |
| `{TYPE} X as Y` | 0 | Type downcast | N/A |

**VERDICT**: No problematic type casts. All attached checks are for void safety.

---

## Collection Type Analysis

### SIMPLE_TEMPLATE Collections

| Attribute | Declared Type | Type-Safe |
|-----------|---------------|-----------|
| variables | HASH_TABLE [STRING, STRING] | YES |
| sections | HASH_TABLE [BOOLEAN, STRING] | YES |
| lists | HASH_TABLE [ARRAYED_LIST [HASH_TABLE [STRING, STRING]], STRING] | YES |
| partials | HASH_TABLE [SIMPLE_TEMPLATE, STRING] | YES |

All collections are properly parameterized.

**VERDICT**: Type-safe collections.

---

## Constrained Genericity Opportunities

**Criteria**: Where type parameters should be constrained

### Analysis

No custom generic classes exist, so no constraint opportunities.

If we were to generify (which we determined is not needed), examples would be:

```eiffel
-- Hypothetical (NOT RECOMMENDED)
class TEMPLATE_CONTEXT [V -> STRINGABLE]
  -- V must have `out` or similar
```

**VERDICT**: Not applicable - no generification needed.

---

## Algorithm Generalization

**Criteria**: Algorithms that could be generic

### Scan Results

| Algorithm | Current Type | Could Generalize | Should? |
|-----------|--------------|------------------|---------|
| escape_html | STRING | No - HTML specific | NO |
| render_template | STRING | No - Template specific | NO |
| list_has_string | STRING | Yes - could be LIST [G] | NO* |

*`list_has_string` could theoretically be generic, but:
1. It's a small helper (10 lines)
2. Only used for STRING lists
3. Standard library has similar features

**VERDICT**: No valuable generalization opportunities.

---

## Genericity Impact Assessment

### Current State

- 0 custom generic classes
- Extensive use of standard library generics
- All types are specific and appropriate

### If Generified

No significant improvement possible:
- Domain is string-based (Mustache templates)
- Variable values must be STRING (Mustache spec)
- No type polymorphism needed

**VERDICT**: Genericity is not applicable to this domain.

---

## Missing Feature: set_variable_any

From specification review, one feature could benefit from ANY:

```eiffel
set_variable_any (a_name: STRING; a_value: ANY)
    -- Set variable from any object (converts via .out).
  require
    name_not_void: a_name /= Void
    name_not_empty: not a_name.is_empty
    value_not_void: a_value /= Void
  do
    set_variable (a_name, a_value.out)
  ensure
    variable_set: has_variable (a_name)
  end
```

**Analysis**:
- Uses ANY for convenience (not type safety)
- Converts to STRING via `.out`
- Minor usability improvement

**Severity**: LOW
**Recommendation**: ADD (identified in spec phase)

---

## Standard Library Generic Usage

The codebase properly uses Eiffel standard generics:

| Generic Used | Purpose | Correct |
|--------------|---------|---------|
| HASH_TABLE [V, K] | Variables, sections, lists, partials | YES |
| ARRAYED_LIST [G] | List items, variable names | YES |
| ARRAY [TUPLE [...]] | Quick API parameters | YES |
| STRING | Not generic, appropriate | YES |

**VERDICT**: Excellent use of standard library generics.

---

## Genericity Score

| Category | Score | Notes |
|----------|-------|-------|
| Duplicate avoidance | 10/10 | No type-specific duplicates |
| Standard generic usage | 10/10 | Proper use of HASH_TABLE, ARRAYED_LIST |
| Type safety | 10/10 | No ANY, no casts |
| Appropriate abstraction | 10/10 | Didn't over-generify |

**Overall Genericity Score: 10/10**

The codebase correctly avoids genericity where not needed while properly using standard library generics.

---

## Implementation Priority

1. **ADD `set_variable_any`** (from spec)
   - Effort: LOW
   - Value: MEDIUM (convenience)
   - Priority: Should implement

No other genericity changes needed.

---

## Next Step

→ D05-REFACTOR-PLAN.md
