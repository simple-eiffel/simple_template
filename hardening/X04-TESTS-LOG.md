# X04: Adversarial Tests Log - simple_template

## Date: 2026-01-18

---

## TESTS WRITTEN

| Test Name | Category | Input | Target Vuln |
|-----------|----------|-------|-------------|
| test_v11_stale_error_after_partial_depth | State | Circular partial | V11 |
| test_v11_error_cleared_on_empty_template | State | Empty template | V11 |
| test_v08_empty_variable_name_in_template | Empty Input | `{{}}` | V08 |
| test_v09_empty_section_name_in_template | Empty Input | `{{#}}{{/}}` | V09 |
| test_v10_partial_variables_not_modified | State | Partial render | V10 |
| test_v15_path_traversal_parent_dir | Injection | `../etc/passwd` | V15 |
| test_v15_absolute_unix_path | Injection | `/etc/passwd` | V15 |
| test_v15_absolute_windows_path | Injection | `C:\Windows\...` | V15 |
| test_v16_path_traversal_write | Injection | `../../../file` | V16 |
| test_empty_string_template | Empty Input | `""` | - |
| test_template_with_null_byte | Special Chars | `Hello%UWorld` | - |
| test_very_long_template | Boundary | 100K chars | - |
| test_very_long_variable_name | Boundary | 10K char name | - |
| test_unclosed_variable_tag | Malformed | `{{name` | V18 |
| test_unclosed_section | Malformed | `{{#section}}...` | V18 |

---

## COMPILATION OUTPUT

```
Eiffel Compilation Manager
Version 25.02.9.8732 - win64

Degree 6: Examining System
Degree 5: Parsing Classes
Degree 4: Analyzing Inheritance
Degree 3: Checking Types
Degree 2: Generating Byte Code
Degree 1: Generating Metadata
Melting System Changes
-------------------------------------------------------------------------------

Warning code: Unused Local
Class: ADVERSARIAL_TESTS
Feature: test_v10_partial_variables_not_modified
Unused local is:
	l_partial_vars_after: INTEGER_32

-------------------------------------------------------------------------------
System Recompiled.
```

---

## TEST EXECUTION OUTPUT

```
simple_template test runner
=============================

  PASS: test_make
  PASS: test_make_from_string
  ... (33 more standard tests) ...
  PASS: test_render_to_file

=== Adversarial Tests ===

-- V11: Stale Error Tests --
  PASS: test_v11_stale_error_after_partial_depth
  PASS: test_v11_error_cleared_on_empty_template

-- V08: Empty Variable Name Tests --
  PASS: test_v08_empty_variable_name_in_template - precondition caught empty name

-- V09: Empty Section Name Tests --
  PASS: test_v09_empty_section_name_in_template - precondition caught empty section

-- V10: Partial State Pollution Tests --
  FAIL: test_v10_partial_variables_not_modified - partial state polluted

-- V15: Path Traversal Read Tests --
  PASS: test_v15_path_traversal_parent_dir - precondition blocked traversal
  PASS: test_v15_absolute_unix_path - precondition blocked absolute path
  PASS: test_v15_absolute_windows_path - precondition blocked Windows path

-- V16: Path Traversal Write Tests --
  PASS: test_v16_path_traversal_write - precondition blocked write traversal

-- Empty Input Tests --
  PASS: test_empty_string_template

-- Special Character Tests --
  RISK: test_template_with_null_byte - null handled, len=11

-- Boundary Tests --
  PASS: test_very_long_template (100K chars)
  PASS: test_very_long_variable_name (10K chars)

-- Malformed Template Tests --
  RISK: test_unclosed_variable_tag - got: Hello {{name World
  RISK: test_unclosed_section - got: {{#section}}content without end

=== Adversarial Summary: 11 pass, 1 fail, 3 risk ===

=============================
Results: 46 passed, 1 failed
TESTS FAILED
```

---

## RESULTS

| Category | Tests | Pass | Fail | Risk |
|----------|-------|------|------|------|
| V11 Stale Error | 2 | 2 | 0 | 0 |
| V08 Empty Variable | 1 | 1 | 0 | 0 |
| V09 Empty Section | 1 | 1 | 0 | 0 |
| V10 Partial Pollution | 1 | 0 | **1** | 0 |
| V15 Path Traversal Read | 3 | 3 | 0 | 0 |
| V16 Path Traversal Write | 1 | 1 | 0 | 0 |
| Empty Input | 1 | 1 | 0 | 0 |
| Special Characters | 1 | 0 | 0 | 1 |
| Boundary | 2 | 2 | 0 | 0 |
| Malformed Templates | 2 | 0 | 0 | 2 |
| **Total** | **15** | **11** | **1** | **3** |

---

## BUGS FOUND

### BUG-001: Partial State Pollution (V10 CONFIRMED)

- **Test**: test_v10_partial_variables_not_modified
- **Input**: Parent template with `{{>child}}` partial, parent has variable `passed_var`
- **Expected**: After render, partial should NOT have `passed_var` variable
- **Actual**: Partial now has `passed_var` - state was polluted!
- **Root Cause**: `render_template` lines 396-402 call `l_partial.set_variable(...)` which permanently modifies the partial's variables hash table
- **Impact**: HIGH - Partial reuse in same or future renders will have polluted state
- **Status**: OPEN - Fix in X08

**Code Location**:
```eiffel
-- render_template lines 396-402 (SIMPLE_TEMPLATE)
from
    a_context.start
until
    a_context.after
loop
    l_partial.set_variable (a_context.key_for_iteration, a_context.item_for_iteration)
    a_context.forth
end
```

---

## RISK FINDINGS

### RISK-001: Null Byte Handling
- **Test**: test_template_with_null_byte
- **Finding**: Null bytes pass through without crash, result length = 11
- **Recommendation**: Document behavior, consider whether this is acceptable

### RISK-002: Unclosed Variable Tag
- **Test**: test_unclosed_variable_tag
- **Finding**: Graceful degradation - outputs literal characters `Hello {{name World`
- **Recommendation**: This is acceptable behavior (fail-safe), document it

### RISK-003: Unclosed Section Tag
- **Test**: test_unclosed_section
- **Finding**: Graceful degradation - outputs literal characters
- **Recommendation**: This is acceptable behavior (fail-safe), document it

---

## ASSAULT CONTRACTS EFFECTIVENESS

| Vulnerability | Assault Contract | Test Result |
|---------------|------------------|-------------|
| V08 Empty Variable | get_variable.name_not_empty | **BLOCKED** - precondition fired |
| V09 Empty Section | is_section_truthy.name_not_empty | **BLOCKED** - precondition fired |
| V10 Partial Pollution | (no contract yet) | **BUG FOUND** |
| V15 Path Traversal Read | make_from_file.no_parent_traversal | **BLOCKED** - precondition fired |
| V16 Path Traversal Write | render_to_file.no_parent_traversal | **BLOCKED** - precondition fired |

---

## FILES MODIFIED

- `testing/adversarial_tests.e` - Created with 15 tests
- `testing/test_app.e` - Added adversarial test runner integration

---

## VERIFICATION CHECKPOINT

```
Compilation: SUCCESS
Tests Run: 50 (35 standard + 15 adversarial)
Tests Passed: 46
Tests Failed: 1
Bugs Found: 1 (V10 Partial State Pollution)
Risk Findings: 3
```

---

## Next Step

→ X05-STRESS-ATTACK.md
