# X09: Hardening Report - simple_template

## Date: 2026-01-18

---

## HARDENING SUMMARY

- **Total defenses added**: 22
- Preconditions: 12 (from X03)
- Postconditions: 6 (from X03)
- Invariants: 2 (from X03)
- Regression tests: 1 (V10)
- Mutation killer tests: 1 (M06)

---

## CONTRACT HARDENING (from X03)

### Preconditions Added

| Class | Feature | Contract | Protects Against |
|-------|---------|----------|------------------|
| SIMPLE_TEMPLATE | make_from_file | no_parent_traversal | V15 path traversal |
| SIMPLE_TEMPLATE | make_from_file | no_absolute_unix | V15 path traversal |
| SIMPLE_TEMPLATE | make_from_file | no_windows_drive | V15 path traversal |
| SIMPLE_TEMPLATE | render_to_file | no_parent_traversal | V16 path traversal |
| SIMPLE_TEMPLATE | render_to_file | no_absolute_unix | V16 path traversal |
| SIMPLE_TEMPLATE | render_to_file | no_windows_drive | V16 path traversal |
| SIMPLE_TEMPLATE | get_variable | name_not_empty | V08 empty variable |
| SIMPLE_TEMPLATE | is_section_truthy | name_not_empty | V09 empty section |
| SIMPLE_TEMPLATE | render_section | name_not_empty | V09 empty section |
| SIMPLE_TEMPLATE_QUICK | file | no_parent_traversal, etc | V15 |
| SIMPLE_TEMPLATE_QUICK | render_to_file | no_parent_traversal, etc | V16 |

### Postconditions Added

| Class | Feature | Contract | Guarantees |
|-------|---------|----------|------------|
| SIMPLE_TEMPLATE | render | source_unchanged | Template not modified |
| SIMPLE_TEMPLATE | render | variables_count_unchanged | Variables not modified |
| SIMPLE_TEMPLATE | render | sections_count_unchanged | Sections not modified |
| SIMPLE_TEMPLATE | render | lists_count_unchanged | Lists not modified |
| SIMPLE_TEMPLATE | render | partials_count_unchanged | Partials not modified |
| SIMPLE_TEMPLATE | render | error_cleared_on_empty | V11 detection |

### Invariants Added

| Class | Contract | Maintains |
|-------|----------|-----------|
| SIMPLE_TEMPLATE | valid_policy | Policy in valid range |
| SIMPLE_TEMPLATE | non_negative_depth | Depth >= 0 |

---

## TEST HARDENING

### Regression Tests

| Test | Bug ID | Verifies |
|------|--------|----------|
| test_v10_partial_variables_not_modified | V10 | Partial state not polluted after render |

### Mutation Killer Tests

| Test | Kills Mutation | Description |
|------|----------------|-------------|
| test_m06_partial_depth_exactly_at_limit | M06 | Verifies >= vs > boundary at depth 100 |

---

## BUG FIX DEFENSES

### V10: Partial State Pollution

**Bug**: Partial template variables permanently modified during render.

**Fix**: Added cleanup loop to remove context variables after render.

**Defenses Added**:
1. **Regression test**: `test_v10_partial_variables_not_modified`
2. **New feature**: `remove_variable(a_name)` with postcondition

---

## MUTATION SURVIVOR DEFENSE

### M06: Boundary Condition (>= vs >)

**Mutation**: `partial_depth >= Max_partial_depth` → `partial_depth > Max_partial_depth`

**Originally survived because**: No test exercised exact boundary.

**Defense Added**:
- `test_m06_partial_depth_exactly_at_limit`: Creates 100-deep partial chain
- Verifies that depth 100 triggers the limit error

**Mutation now**: KILLED by test

---

## LIMIT DOCUMENTATION

| Feature | Limit | Enforcement |
|---------|-------|-------------|
| Max_partial_depth | 100 | Constant + runtime check |
| Template size | No limit | Tested to 100K chars |
| Variable count | No limit | Tested to 5000 |
| List size | No limit | Tested to 1000 items |
| Variable value | No limit | Tested to 1MB |

---

## VERIFICATION RESULTS

| Check | Result |
|-------|--------|
| All contracts compile | ✓ YES |
| All tests pass | ✓ YES (48 total) |
| All defenses active | ✓ YES |
| V10 regression test catches bug | ✓ YES |
| M06 mutation now killed | ✓ YES |

---

## DEFENSE COVERAGE

| Metric | Coverage |
|--------|----------|
| Bugs with regression tests | 1/1 (100%) |
| Bugs with protective contracts | 1/1 (100%) |
| Surviving mutations now killed | 1/1 (100%) |
| Path traversal defenses | 6 preconditions |
| Empty name defenses | 3 preconditions |

---

## TEST SUMMARY

```
simple_template test runner
=============================
Results: 48 passed, 0 failed
ALL TESTS PASSED

Breakdown:
- Original tests: 35
- Adversarial tests: 13 (+ 3 risk findings)
- Stress tests: 9
```

---

## FILES MODIFIED

- `testing/adversarial_tests.e`: Added `test_m06_partial_depth_exactly_at_limit`
- Assault contracts from X03 remain as permanent hardening

---

## Next Step

→ X10-VERIFY-HARDENING.md
