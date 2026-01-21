# M06: Fix Contracts - simple_template

## Date: 2026-01-18
## Based on: M02-CONTRACT-AUDIT.md

---

## CHANGES MADE

### SIMPLE_TEMPLATE

#### Postconditions Added

| Feature | Line | Contract Added |
|---------|------|----------------|
| render_template | 441-442 | `ensure result_attached: Result /= Void` |
| render_section | 488-489 | `ensure result_attached: Result /= Void` |
| extract_variables | 641-642 | `ensure result_attached: Result /= Void` |

#### Invariants Strengthened

| Line | Invariant Added |
|------|-----------------|
| 664 | `valid_policy: missing_variable_policy >= Policy_empty_string and missing_variable_policy <= Policy_keep_placeholder` |
| 665 | `non_negative_depth: partial_depth >= 0` |

---

### SIMPLE_TEMPLATE_QUICK

#### Preconditions Added

| Feature | Contract Added |
|---------|----------------|
| render | `vars_not_void: a_vars /= Void` |
| render_raw | `vars_not_void: a_vars /= Void` |
| file | `vars_not_void: a_vars /= Void` |
| substitute | `replacements_not_void: a_replacements /= Void` |
| render_if | `template_not_empty: not a_template.is_empty`, `vars_not_void: a_vars /= Void` |
| render_choice | `true_template_not_empty: not a_true_template.is_empty`, `false_template_not_empty: not a_false_template.is_empty`, `vars_not_void: a_vars /= Void` |
| render_list | `items_not_void: a_items /= Void` |
| render_to_file | `vars_not_void: a_vars /= Void` |

#### Spec Comments Improved

| Feature | Comment Added |
|---------|---------------|
| file | "Returns empty string if file cannot be read." |
| render_to_file | "File is created or overwritten." |

---

## SUMMARY

| Category | Count |
|----------|-------|
| Postconditions added | 3 |
| Invariants added | 2 |
| Preconditions added | 11 |
| Spec comments improved | 2 |

**Total contract improvements: 18**

---

## RISK ASSESSMENT

| Contract | Risk | Reason |
|----------|------|--------|
| result_attached postconditions | LOW | All returns already non-Void |
| valid_policy invariant | LOW | Policy set only in make or set_missing_variable_policy |
| non_negative_depth invariant | LOW | Depth only incremented by 1 from 0 |
| a_vars preconditions | MEDIUM | Callers must ensure arrays not Void |

---

## Next Step

→ M07-COMPILE-VALIDATE.md
