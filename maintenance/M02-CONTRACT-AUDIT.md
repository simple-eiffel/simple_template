# M02: Contract Audit - simple_template

## Date: 2026-01-18
## Files Audited:
- D:\prod\simple_template\src\simple_template.e
- D:\prod\simple_template\src\simple_template_quick.e

---

## CLASS: SIMPLE_TEMPLATE

### INVARIANT AUDIT

**Current Invariant (lines 652-657):**
```eiffel
invariant
    template_source_attached: template_source /= Void
    variables_attached: variables /= Void
    sections_attached: sections /= Void
    lists_attached: lists /= Void
    partials_attached: partials /= Void
```

| Check | Status |
|-------|--------|
| Has invariant clause? | ✓ YES |
| Invariant captures class-level truths? | Partial |
| Invariant aligns with specification? | ✓ YES |
| Invariant aligns with domain rules? | Partial |

**Missing Invariants:**
- `valid_policy: missing_variable_policy >= Policy_empty_string and missing_variable_policy <= Policy_keep_placeholder`
- `non_negative_depth: partial_depth >= 0`

**Status: PRESENT - Could strengthen**

### PRECONDITION AUDIT

| Feature | Pre Status | Details |
|---------|------------|---------|
| make | ABSENT | OK - no args |
| make_from_string | ADEQUATE | template_not_void |
| make_from_file | ADEQUATE | path_not_void, path_not_empty |
| set_escape_html | ABSENT | OK - boolean arg |
| set_missing_variable_policy | ADEQUATE | valid_policy range check |
| register_partial | ADEQUATE | name/template not void |
| set_variable | ADEQUATE | name/value not void |
| set_variable_any | ADEQUATE | name/value not void |
| set_variables | ADEQUATE | table_not_void |
| set_section | ADEQUATE | name not void |
| set_list | ADEQUATE | name/items not void |
| clear_variables | ABSENT | OK - no args |
| render | ABSENT | OK - no args |
| render_with_depth | ADEQUATE | valid_depth >= 0 |
| render_to_file | ADEQUATE | path not void |
| has_variable | ADEQUATE | name_not_void |
| required_variables | ABSENT | OK - no args |
| is_valid | ABSENT | OK - no args |
| render_template | ADEQUATE | source/context not void |
| render_section | ADEQUATE | all args not void |
| is_section_truthy | ADEQUATE | name_not_void |
| get_variable | ADEQUATE | name/context not void |
| escape_html | ADEQUATE | value_not_void |
| extract_variables | ADEQUATE | source_not_void |
| list_has_string | ADEQUATE | list/string not void |

**Precondition Coverage: 100%** (all needed preconditions present)

### POSTCONDITION AUDIT

| Feature | Post Status | Details |
|---------|-------------|---------|
| make | WEAK | Has empty_source, escape_enabled; missing policy_set |
| make_from_string | ADEQUATE | source_set |
| make_from_file | ABSENT | Should ensure state set |
| set_escape_html | ADEQUATE | set |
| set_missing_variable_policy | ADEQUATE | policy_set |
| register_partial | ADEQUATE | registered |
| set_variable | ADEQUATE | variable_set |
| set_variable_any | ADEQUATE | variable_set |
| set_variables | ABSENT | Should ensure all vars set |
| set_section | ADEQUATE | section_set |
| set_list | ADEQUATE | list_set |
| clear_variables | ADEQUATE | all empty |
| render | ADEQUATE | result_attached |
| render_with_depth | ADEQUATE | result_attached |
| render_to_file | ABSENT | Should ensure file written |
| has_variable | ABSENT | OK - boolean query |
| required_variables | ADEQUATE | result_attached |
| is_valid | ABSENT | Could add Result = (last_error = Void) |
| render_template | ABSENT | Should add result_attached |
| render_section | ABSENT | Should add result_attached |
| is_section_truthy | ABSENT | OK - boolean query |
| get_variable | ADEQUATE | result_attached |
| escape_html | ADEQUATE | result_attached |
| extract_variables | ABSENT | Should add result_attached |
| list_has_string | ABSENT | OK - boolean query |

**Missing Postconditions:**
1. make_from_file: no postcondition
2. set_variables: no postcondition
3. render_to_file: no postcondition
4. render_template: no postcondition
5. render_section: no postcondition
6. extract_variables: no postcondition

---

## CLASS: SIMPLE_TEMPLATE_QUICK

### INVARIANT AUDIT

**Current Invariant (lines 207-208):**
```eiffel
invariant
    logger_exists: logger /= Void
```

**Status: ADEQUATE**

### PRECONDITION AUDIT

| Feature | Pre Status | Details |
|---------|------------|---------|
| make | ABSENT | OK - no args |
| render | WEAK | template_not_empty; missing a_vars not void |
| render_raw | WEAK | template_not_empty; missing a_vars not void |
| file | WEAK | path_not_empty; missing a_vars not void |
| substitute | WEAK | template_not_empty; missing a_replacements not void |
| render_if | ABSENT | Missing template/vars checks |
| render_choice | ABSENT | Missing template/vars checks |
| render_list | WEAK | template_not_empty; missing a_items not void |
| render_to_file | WEAK | Missing a_vars not void |
| variables_in | ADEQUATE | template_not_empty |
| is_valid | ADEQUATE | template_not_empty |

**Missing Preconditions:**
1. render: a_vars not void
2. render_raw: a_vars not void
3. file: a_vars not void
4. substitute: a_replacements not void
5. render_if: template not empty, a_vars not void
6. render_choice: templates not empty, a_vars not void
7. render_list: a_items not void
8. render_to_file: a_vars not void

### POSTCONDITION AUDIT

| Feature | Post Status | Details |
|---------|-------------|---------|
| make | ADEQUATE | logger_exists |
| render | ADEQUATE | result_exists |
| render_raw | ADEQUATE | result_exists |
| file | ADEQUATE | result_exists |
| substitute | ADEQUATE | result_exists |
| render_if | ADEQUATE | result_exists |
| render_choice | ADEQUATE | result_exists |
| render_list | ADEQUATE | result_exists |
| render_to_file | ABSENT | Should ensure file written |
| variables_in | ADEQUATE | result_exists |
| is_valid | ABSENT | OK - boolean query |

**Missing Postconditions:**
1. render_to_file: no postcondition

---

## CONTRACT SCORE

### SIMPLE_TEMPLATE

| Metric | Value |
|--------|-------|
| Features with preconditions | 100% (where needed) |
| Features with postconditions | 70% |
| Invariant present | YES |
| Invariant complete | 85% |

**Score: 8/10**

### SIMPLE_TEMPLATE_QUICK

| Metric | Value |
|--------|-------|
| Features with preconditions | 45% |
| Features with postconditions | 90% |
| Invariant present | YES |
| Invariant complete | 100% |

**Score: 7/10**

---

## PRIORITY FIXES

### HIGH Priority (Missing array/tuple preconditions)

1. **SIMPLE_TEMPLATE_QUICK.render**: Add `a_vars_not_void: a_vars /= Void`
2. **SIMPLE_TEMPLATE_QUICK.render_raw**: Add `a_vars_not_void: a_vars /= Void`
3. **SIMPLE_TEMPLATE_QUICK.file**: Add `a_vars_not_void: a_vars /= Void`
4. **SIMPLE_TEMPLATE_QUICK.substitute**: Add `a_replacements_not_void: a_replacements /= Void`
5. **SIMPLE_TEMPLATE_QUICK.render_if**: Add template/vars preconditions
6. **SIMPLE_TEMPLATE_QUICK.render_choice**: Add template/vars preconditions
7. **SIMPLE_TEMPLATE_QUICK.render_list**: Add `a_items_not_void: a_items /= Void`
8. **SIMPLE_TEMPLATE_QUICK.render_to_file**: Add `a_vars_not_void: a_vars /= Void`

### MEDIUM Priority (Missing postconditions)

1. **SIMPLE_TEMPLATE.render_template**: Add `result_attached: Result /= Void`
2. **SIMPLE_TEMPLATE.render_section**: Add `result_attached: Result /= Void`
3. **SIMPLE_TEMPLATE.extract_variables**: Add `result_attached: Result /= Void`

### LOW Priority (Strengthen invariants)

1. **SIMPLE_TEMPLATE**: Add `valid_policy` invariant
2. **SIMPLE_TEMPLATE**: Add `non_negative_depth` invariant

---

## Next Step

→ M03-CODE-AUDIT.md
