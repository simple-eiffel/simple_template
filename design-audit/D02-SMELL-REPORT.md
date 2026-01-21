# SMELL DETECTION REPORT: simple_template

## Date: 2026-01-18
## Source: Actual codebase analysis

---

## Smell Summary

| Smell Type | Count | High | Medium | Low |
|------------|-------|------|--------|-----|
| God Class | 0 | 0 | 0 | 0 |
| Feature Envy | 0 | 0 | 0 | 0 |
| Long Param List | 1 | 0 | 0 | 1 |
| Data Clumps | 1 | 0 | 1 | 0 |
| Primitive Obsession | 1 | 0 | 1 | 0 |
| Dead Code | 0 | 0 | 0 | 0 |
| Inappropriate Intimacy | 0 | 0 | 0 | 0 |
| Speculative Generality | 0 | 0 | 0 | 0 |
| Comment Smells | 0 | 0 | 0 | 0 |
| Long Method | 1 | 0 | 1 | 0 |
| **TOTAL** | **4** | **0** | **3** | **1** |

---

## SMELL: GOD CLASS

**Detection criteria:**
- > 20 features
- > 300 lines of code
- Multiple distinct responsibilities
- Many dependencies on other classes

### Analysis

**SIMPLE_TEMPLATE**: 619 lines, 40 features

| Criterion | Value | Threshold | Exceeded |
|-----------|-------|-----------|----------|
| Features | 40 | > 20 | YES |
| Lines | 619 | > 300 | YES |
| Responsibilities | 1 (template engine) | Multiple | NO |
| Dependencies | 4 (standard library) | Many | NO |

**VERDICT**: NOT A GOD CLASS

Despite exceeding size thresholds, SIMPLE_TEMPLATE has a **single clear responsibility** (Mustache template engine) and all features relate to that purpose. The size is due to:
- Comprehensive Mustache feature coverage
- All tag types (variable, section, inverted, comment, partial, raw)
- Policy handling
- HTML escaping

This is an appropriately-sized facade, not a God class.

---

## SMELL: FEATURE ENVY

**Detection criteria:**
- Feature accesses > 3 features of another class
- Feature accesses more external data than own class data

### Scan Results

Scanned all features for external access patterns:

| Feature | Own Class Access | External Access | Envy? |
|---------|------------------|-----------------|-------|
| render_template | 6+ (variables, sections, lists, partials, escape_html_enabled, missing_variable_policy) | 0 | NO |
| render_section | 3 (lists, a_context, render_template) | 0 | NO |
| QUICK.render | 1 (logger) | Creates SIMPLE_TEMPLATE (appropriate) | NO |

**VERDICT**: NO FEATURE ENVY DETECTED

All features primarily operate on their own class's data.

---

## SMELL: LONG PARAMETER LIST

**Detection criteria:**
- > 4 parameters
- Multiple parameters of same type
- Related parameters travel together

### Scan Results

| Class | Feature | Params | Issue |
|-------|---------|--------|-------|
| SIMPLE_TEMPLATE | set_list | 2 | OK |
| SIMPLE_TEMPLATE | render_template | 2 | OK |
| SIMPLE_TEMPLATE | render_section | 3 | OK |
| SIMPLE_TEMPLATE_QUICK | render | 2 | OK |
| SIMPLE_TEMPLATE_QUICK | render_choice | 4 | BORDERLINE |
| SIMPLE_TEMPLATE_QUICK | render_to_file | 3 | OK |

**LONG PARAM LIST CANDIDATE**:

```eiffel
render_choice (a_condition: BOOLEAN;
               a_true_template, a_false_template: STRING;
               a_vars: ARRAY [TUPLE [name: STRING; value: STRING]]): STRING
```

- Parameters: 4
- Severity: **LOW**
- RECOMMENDATION: Acceptable. Could introduce `TEMPLATE_CHOICE` parameter object if more choices added in future, but not needed now.

---

## SMELL: DATA CLUMPS

**Detection criteria:**
- Same 3+ fields in multiple classes
- Same 3+ parameters in multiple features

### Scan Results

**DATA CLUMP FOUND**: Variable tuple pattern

Appears in SIMPLE_TEMPLATE_QUICK multiple times:
- `render (a_vars: ARRAY [TUPLE [name: STRING; value: STRING]])`
- `render_raw (a_vars: ARRAY [TUPLE [name: STRING; value: STRING]])`
- `file (a_vars: ARRAY [TUPLE [name: STRING; value: STRING]])`
- `render_if (a_vars: ARRAY [TUPLE [name: STRING; value: STRING]])`
- `render_choice (a_vars: ARRAY [TUPLE [name: STRING; value: STRING]])`
- `render_list (a_items: ARRAY [ARRAY [TUPLE [name: STRING; value: STRING]]])`
- `render_to_file (a_vars: ARRAY [TUPLE [name: STRING; value: STRING]])`
- `variables_in` (no vars param, but same pattern)

**Severity**: MEDIUM

**RECOMMENDATION**: This is intentional design for one-liner convenience. The TUPLE provides inline initialization: `<<["name", "value"]>>`. While verbose, it's the Eiffel way to support one-liner calls. Acceptable as-is.

---

## SMELL: PRIMITIVE OBSESSION

**Detection criteria:**
- STRING used for emails, phones, URLs, IDs
- INTEGER used for money, quantities with units
- Type implies validation or formatting

### Scan Results

**PRIMITIVE OBSESSION CANDIDATE**:

```eiffel
missing_variable_policy: INTEGER
    -- Policy for missing variables.
    -- One of: Policy_empty_string, Policy_raise_exception, Policy_keep_placeholder

Policy_empty_string: INTEGER = 1
Policy_raise_exception: INTEGER = 2
Policy_keep_placeholder: INTEGER = 3
```

**Analysis**:
- Type: INTEGER
- Semantic: Policy enumeration
- Should be: Expanded enumeration class or at least named constants with type alias
- Validation: Done via precondition (acceptable but fragile)

**Severity**: MEDIUM

**RECOMMENDATION**: Consider creating `TEMPLATE_MISSING_POLICY` as an expanded class with `empty_string`, `keep_placeholder`, `raise_exception` creation. However, INTEGER constants with precondition validation is a common Eiffel pattern and works correctly.

**VERDICT**: Low priority fix. Current implementation works and is idiomatic Eiffel.

---

## SMELL: DEAD CODE

**Detection criteria:**
- Features never called
- Branches never reached
- Classes never instantiated

### Scan Results

Analyzed all features against test coverage and usage:

| Feature | Called From | Status |
|---------|-------------|--------|
| SIMPLE_TEMPLATE.make | Tests, SIMPLE_TEMPLATE_QUICK | USED |
| SIMPLE_TEMPLATE.make_from_string | Tests, QUICK | USED |
| SIMPLE_TEMPLATE.make_from_file | Tests, QUICK.file | USED |
| SIMPLE_TEMPLATE.render_to_file | Untested | **VERIFY** |
| list_has_string | extract_variables | USED |
| All other features | Tests | USED |

**POTENTIALLY DEAD**: `render_to_file` in SIMPLE_TEMPLATE

- No test coverage
- May be called by clients externally
- Recommendation: Add test, keep feature

**VERDICT**: NO CONFIRMED DEAD CODE

---

## SMELL: INAPPROPRIATE INTIMACY

**Detection criteria:**
- Accessing private/internal features
- Circular dependencies
- Changing behavior based on other class's internals

### Scan Results

| Relationship | Intimacy Check |
|--------------|----------------|
| QUICK → TEMPLATE | Uses public API only (make_from_string, set_variable, render) | OK |
| TEMPLATE → TEMPLATE | Self-reference in partials | OK (appropriate for partials) |
| Tests → Classes | Uses public API only | OK |

**VERDICT**: NO INAPPROPRIATE INTIMACY

---

## SMELL: SPECULATIVE GENERALITY

**Detection criteria:**
- Abstract classes with only one concrete child
- Unused parameters "for future use"
- Overly generic when only one type used

### Scan Results

- No deferred classes
- No unused parameters
- No overly generic code
- Policy constants are used

**VERDICT**: NO SPECULATIVE GENERALITY

The design is appropriately minimal.

---

## SMELL: COMMENT SMELLS

**Detection criteria:**
- Long explanatory comments
- Comments that could be code (extract method)
- Apologetic comments ("this is a hack")

### Scan Results

All comments in the codebase:
- Class notes (appropriate documentation)
- Feature contracts (appropriate)
- Brief inline comments explaining tag types (appropriate)

**VERDICT**: NO COMMENT SMELLS

---

## SMELL: LONG METHOD

**Detection criteria:**
- Method > 50 lines
- Complex nested logic
- Multiple responsibilities in single method

### Scan Results

| Class | Feature | Lines | Complexity |
|-------|---------|-------|------------|
| SIMPLE_TEMPLATE | render_template | ~144 | HIGH |
| SIMPLE_TEMPLATE | render_section | ~45 | MEDIUM |
| SIMPLE_TEMPLATE | escape_html | ~25 | LOW |

**LONG METHOD**: `render_template`

```
Lines: 258-401 = 144 lines
Complexity: Multiple nested conditionals for each tag type
Structure: Large from/until loop with many elseif branches
```

**Severity**: MEDIUM

**RECOMMENDATION**: Extract tag-specific processing into separate features:
- `process_comment_tag`
- `process_raw_tag`
- `process_inverted_section_tag`
- `process_section_tag`
- `process_partial_tag`
- `process_variable_tag`

However, the current structure:
1. Works correctly (all tests pass)
2. Has clear structure (each elseif handles one tag type)
3. Would add complexity with many small methods

**VERDICT**: Acceptable for now. Consider refactoring if adding new tag types.

---

## High Severity Smells

**None found.**

---

## Medium Severity Smells

1. **Long Method**: `render_template` (144 lines)
   - Risk: Harder to modify/extend
   - Recommendation: Consider extracting tag processors if adding features

2. **Data Clump**: Variable tuple pattern in QUICK
   - Risk: Verbose signatures
   - Recommendation: Acceptable as-is (intentional for one-liner API)

3. **Primitive Obsession**: Policy as INTEGER
   - Risk: Invalid values possible without contract
   - Recommendation: Current precondition validation is sufficient

---

## Low Severity Smells

1. **Long Param List**: `render_choice` has 4 parameters
   - Risk: Minimal
   - Recommendation: No change needed

---

## Top Refactoring Opportunities

1. **Extract tag processors from render_template** (MEDIUM effort, MEDIUM value)
   - Would improve readability
   - Would make adding new tags easier
   - Not urgent - current code works

2. **Add missing `set_variable_any` feature** (LOW effort, HIGH value)
   - Identified in spec as missing
   - Would improve usability
   - Should be added

3. **Add tests for `render_to_file`** (LOW effort, HIGH value)
   - Currently untested
   - Simple to add

---

## Smell Score

| Category | Score |
|----------|-------|
| God Class | 0/10 (clean) |
| Feature Envy | 0/10 (clean) |
| Long Param List | 1/10 (minor) |
| Data Clumps | 3/10 (acceptable pattern) |
| Primitive Obsession | 2/10 (minor) |
| Dead Code | 0/10 (clean) |
| Inappropriate Intimacy | 0/10 (clean) |
| Speculative Generality | 0/10 (clean) |
| Comment Smells | 0/10 (clean) |
| Long Method | 4/10 (notable but acceptable) |

**Overall Smell Score: 10/100** (Excellent - minimal smells)

---

## Next Step

→ D03-INHERITANCE-AUDIT.md
