# X01: Reconnaissance - simple_template

## Date: 2026-01-18

## Baseline Verification

### Compilation
```
Eiffel Compilation Manager
Version 25.02.9.8732 - win64

Degree 6: Examining System
System Recompiled.
```

### Test Run
```
simple_template test runner
=============================
  PASS: test_make
  PASS: test_make_from_string
  ... (33 more)
  PASS: test_render_to_file
=============================
Results: 35 passed, 0 failed
ALL TESTS PASSED
```

### Baseline Status
- Compiles: YES
- Tests: 35 pass, 0 fail
- Warnings: 1 (unused locals in render_template)

---

## Source Files

| File | Class | Lines | Features | Contracts |
|------|-------|-------|----------|-----------|
| simple_template.e | SIMPLE_TEMPLATE | 668 | 26 public, 10 private | 20 pre, 16 post, 7 inv |
| simple_template_quick.e | SIMPLE_TEMPLATE_QUICK | 221 | 11 | 11 pre, 10 post, 1 inv |

---

## Public API Analysis

### SIMPLE_TEMPLATE

| Feature | Type | Params | Pre | Post | Risk |
|---------|------|--------|-----|------|------|
| make | creation | 0 | 0 | 2 | L |
| make_from_string | creation | STRING | 1 | 1 | L |
| make_from_file | creation | STRING | 2 | 0 | **H** |
| set_escape_html | command | BOOLEAN | 0 | 1 | L |
| set_missing_variable_policy | command | INTEGER | 1 | 1 | L |
| register_partial | command | STRING, TEMPLATE | 3 | 1 | M |
| set_variable | command | STRING, STRING | 3 | 1 | L |
| set_variable_any | command | STRING, ANY | 3 | 1 | L |
| set_variables | command | HASH_TABLE | 1 | 0 | M |
| set_section | command | STRING, BOOLEAN | 2 | 1 | L |
| set_list | command | STRING, LIST | 3 | 1 | L |
| clear_variables | command | 0 | 0 | 3 | L |
| render | query | 0 | 0 | 1 | M |
| render_to_file | command | STRING | 2 | 0 | **H** |
| has_variable | query | STRING | 1 | 0 | L |
| required_variables | query | 0 | 0 | 1 | L |
| is_valid | query | 0 | 0 | 0 | L |

### SIMPLE_TEMPLATE_QUICK

| Feature | Type | Params | Pre | Post | Risk |
|---------|------|--------|-----|------|------|
| make | creation | 0 | 0 | 1 | L |
| render | query | STRING, ARRAY | 2 | 1 | M |
| render_raw | query | STRING, ARRAY | 2 | 1 | **H** |
| file | query | STRING, ARRAY | 2 | 1 | **H** |
| substitute | query | STRING, ARRAY | 2 | 1 | M |
| render_if | query | BOOL, STRING, ARRAY | 3 | 1 | M |
| render_choice | query | BOOL, STRING, STRING, ARRAY | 4 | 1 | M |
| render_list | query | STRING, ARRAY | 2 | 1 | M |
| render_to_file | command | STRING, ARRAY, STRING | 3 | 0 | **H** |
| variables_in | query | STRING | 1 | 1 | L |
| is_valid | query | STRING | 1 | 0 | L |

---

## Contract Coverage Summary

| Metric | SIMPLE_TEMPLATE | SIMPLE_TEMPLATE_QUICK |
|--------|-----------------|----------------------|
| Total features | 26 | 11 |
| With preconditions | 18 (69%) | 11 (100%) |
| With postconditions | 16 (62%) | 10 (91%) |
| Has invariant | YES (7) | YES (1) |

---

## Attack Surface Priority

### HIGH RISK (Primary Targets)

1. **SIMPLE_TEMPLATE.make_from_file** - File read with user path
   - No postcondition
   - Path traversal possible
   - Error handling unclear

2. **SIMPLE_TEMPLATE.render_to_file** - File write with user path
   - No postcondition
   - Could overwrite arbitrary files
   - No error handling

3. **SIMPLE_TEMPLATE_QUICK.render_raw** - No HTML escaping
   - XSS if output used in HTML
   - Intentional but dangerous

4. **SIMPLE_TEMPLATE_QUICK.file** - File read facade
   - Inherits make_from_file risks

5. **SIMPLE_TEMPLATE_QUICK.render_to_file** - File write facade
   - Inherits render_to_file risks

### MEDIUM RISK (Secondary Targets)

1. **render_template** - Complex parsing (150 lines)
   - Many substring operations
   - Edge cases in malformed templates
   - Recursive calls

2. **set_variables** - No postcondition
   - Bulk operation, partial failure?

3. **is_section_truthy** - Complex logic
   - Many code paths
   - Falsy value detection

4. **escape_html** - Security critical
   - Must catch ALL dangerous chars
   - What about Unicode?

### LOW RISK (Well Protected)

1. set_variable, set_section, set_list - Good contracts
2. make, make_from_string - Simple, protected
3. has_variable, required_variables - Read-only queries

---

## Potential Attack Vectors

### 1. Empty Template Attacks
- What if template_source is empty?
- What if template has only `{{}}`?
- What if template has unclosed tags?

### 2. Boundary Attacks
- Very long template strings
- Very long variable names
- Very long variable values
- Deeply nested sections

### 3. Malformed Input Attacks
- `{{` without `}}`
- `{{{` without `}}}`
- `{{#section}}` without `{{/section}}`
- Nested sections with same name

### 4. Resource Exhaustion
- Circular partials (protected by depth limit)
- Huge list iteration
- Template that expands exponentially

### 5. Injection Attacks
- XSS via unescaped output
- Path traversal via file operations
- Template injection via user input

---

## VERIFICATION CHECKPOINT

```
Compilation output: [PASTED - System Recompiled]
Test output: [PASTED - 35/35 pass]
Source files read: 2
Attack surfaces listed: 17 (5 HIGH, 4 MEDIUM, 8 LOW)
hardening/X01-RECON-ACTUAL.md: [CREATED]
```

---

## Next Step

→ X02-VULNERABILITY-SCAN.md
