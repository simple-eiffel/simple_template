# X03: Contract Assault Report - simple_template

## Date: 2026-01-18

---

## ASSAULT SUMMARY

- Contracts deployed: 19
- Contract failures during normal tests: 0
- Bugs revealed by existing tests: 0

**Analysis**: Assault contracts added successfully. Existing test suite does not trigger vulnerabilities (tests are "happy path"). Adversarial tests needed in X04 to expose bugs.

---

## CONTRACTS ADDED

### SIMPLE_TEMPLATE

#### Postconditions Added (render)

| Feature | Contract | Purpose | Result |
|---------|----------|---------|--------|
| render | source_unchanged: template_source.same_string (old template_source.twin) | Verify render is pure query | PASS |
| render | variables_count_unchanged: variables.count = old variables.count | Verify render doesn't modify variables | PASS |
| render | sections_count_unchanged: sections.count = old sections.count | Verify render doesn't modify sections | PASS |
| render | lists_count_unchanged: lists.count = old lists.count | Verify render doesn't modify lists | PASS |
| render | partials_count_unchanged: partials.count = old partials.count | Verify render doesn't modify partials | PASS |
| render | error_cleared_on_empty: template_source.is_empty implies is_valid | Expose V11 stale error | PASS* |

*Note: PASS because existing tests don't exercise the V11 bug scenario (render after error, then render empty)

#### Preconditions Added (path traversal defense)

| Feature | Contract | Purpose | Result |
|---------|----------|---------|--------|
| make_from_file | no_parent_traversal: not a_path.has_substring ("..") | Block V15 path traversal | PASS* |
| make_from_file | no_absolute_unix: a_path.count > 0 implies a_path.item (1) /= '/' | Block absolute paths | PASS* |
| make_from_file | no_windows_drive: a_path.count >= 2 implies not (a_path.item (2) = ':') | Block Windows absolute | PASS* |
| render_to_file | no_parent_traversal: not a_path.has_substring ("..") | Block V16 path traversal | PASS* |
| render_to_file | no_absolute_unix: a_path.count > 0 implies a_path.item (1) /= '/' | Block absolute paths | PASS* |
| render_to_file | no_windows_drive: a_path.count >= 2 implies not (a_path.item (2) = ':') | Block Windows absolute | PASS* |

*Note: PASS because existing tests use safe relative paths

#### Preconditions Added (empty name defense)

| Feature | Contract | Purpose | Result |
|---------|----------|---------|--------|
| get_variable | name_not_empty: not a_name.is_empty | Block V08 empty var name | PASS* |
| is_section_truthy | name_not_empty: not a_name.is_empty | Block V09 empty section | PASS* |
| render_section | name_not_empty: not a_name.is_empty | Block V09 empty section | PASS* |

*Note: PASS because existing tests don't use templates with empty names `{{}}`

### SIMPLE_TEMPLATE_QUICK

#### Preconditions Added (path traversal defense)

| Feature | Contract | Purpose | Result |
|---------|----------|---------|--------|
| file | no_parent_traversal, no_absolute_unix, no_windows_drive | Block V15 | PASS* |
| render_to_file | no_parent_traversal, no_absolute_unix, no_windows_drive | Block V16 | PASS* |

*Note: PASS because existing tests use safe paths

---

## BUGS EXPOSED

**NONE by existing tests**

The current test suite is too polite. It uses valid inputs that don't trigger the assault contracts. This is a finding in itself: the test suite lacks adversarial coverage.

---

## CONTRACTS THAT HARDENED CODE

All 19 contracts are now active defenses. They will catch:
- V08: Empty variable names in templates `{{}}`
- V09: Empty section names in templates `{{#}}`
- V11: Stale error state (for empty templates)
- V15: Path traversal in file reads
- V16: Path traversal in file writes

---

## ANALYSIS: WHY NO BUGS FOUND

1. **Happy-path tests**: All 35 tests use valid, well-formed inputs
2. **No malicious paths**: File tests use relative paths without traversal
3. **No empty names**: No template contains `{{}}` or `{{#}}`
4. **No stale error scenario**: Tests don't render after error

---

## NEXT ATTACKS (for X04)

Write adversarial tests that:

1. **V11 Stale Error Test**:
   - Render template that triggers error (e.g., partial depth)
   - Change to empty template
   - Render again
   - Assert is_valid = True (will fail, exposing V11)

2. **V08/V09 Empty Name Tests**:
   - Template `{{}}` - empty variable
   - Template `{{#}}content{{/}}` - empty section
   - These should trigger precondition failures

3. **V15/V16 Path Traversal Tests**:
   - make_from_file("../etc/passwd") - should fail precondition
   - render_to_file("../../../important.txt") - should fail precondition
   - make_from_file("C:\Windows\System32\file") - should fail precondition

4. **V10 Partial State Pollution Test**:
   - Create partial with no variables
   - Render parent with variables, using partial
   - Check partial still has no variables (may fail if V10 exists)

---

## COMPILATION RESULT

```
System Recompiled.
Warning: Unused locals in render_template (pre-existing)
```

---

## TEST RUN RESULT

```
35 passed, 0 failed
ALL TESTS PASSED
```

---

## CONCLUSION

Assault contracts are deployed and hardening the code. Existing tests don't trigger them because they're too well-behaved. X04 will write tests specifically designed to break things.

---

## FILES MODIFIED

```
src/simple_template.e
  - Lines 185-195: Added 6 postconditions to render
  - Lines 49-52: Added 3 preconditions to make_from_file
  - Lines 221-224: Added 3 preconditions to render_to_file
  - Line 546: Added name_not_empty to get_variable
  - Line 513: Added name_not_empty to is_section_truthy
  - Line 466: Added name_not_empty to render_section

src/simple_template_quick.e
  - Lines 85-88: Added 3 preconditions to file
  - Lines 184-187: Added 3 preconditions to render_to_file
```

---

## Next Step

→ X04-ADVERSARIAL-TESTS.md
