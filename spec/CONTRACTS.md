# Contracts: simple_template

## Date: 2026-01-18

---

## Contract Philosophy

simple_template uses Design by Contract (DBC) as a formal specification mechanism:

1. **Preconditions** define what callers must provide
2. **Postconditions** define what the feature guarantees
3. **Invariants** define what is always true about class instances
4. **Semantic postconditions** verify meaning, not just syntax

Contracts serve as executable documentation and formal correctness guarantees.

---

## Contract Statistics

| Metric | Count |
|--------|-------|
| Classes | 2 |
| Features with contracts | 32 |
| Preconditions | 28 |
| Postconditions | 32 |
| Invariants | 7 |
| Coverage | 100% |

---

## Invariants by Class

### SIMPLE_TEMPLATE

```eiffel
invariant
    -- DR-001: Template source must be non-void
    template_source_attached: template_source /= Void

    -- DR-008: All internal tables must be non-void
    variables_attached: variables /= Void
    sections_attached: sections /= Void
    lists_attached: lists /= Void
    partials_attached: partials /= Void

    -- DR-010: Policy must be valid
    valid_policy: missing_variable_policy >= Policy_empty_string
                  and missing_variable_policy <= Policy_raise_exception
```

### SIMPLE_TEMPLATE_QUICK

```eiffel
invariant
    logger_attached: logger /= Void
```

---

## Preconditions by Feature

### SIMPLE_TEMPLATE Creation

```eiffel
-- make: no preconditions

make_from_string (a_template: STRING)
  require
    template_not_void: a_template /= Void

make_from_file (a_path: STRING)
  require
    path_not_void: a_path /= Void
    path_not_empty: not a_path.is_empty
```

### SIMPLE_TEMPLATE Queries

```eiffel
has_variable (a_name: STRING)
  require
    name_not_void: a_name /= Void

-- Other queries: no preconditions (always callable)
```

### SIMPLE_TEMPLATE Configuration

```eiffel
-- set_escape_html: no preconditions

set_missing_variable_policy (a_policy: INTEGER)
  require
    valid_policy: a_policy >= Policy_empty_string
                  and a_policy <= Policy_raise_exception

register_partial (a_name: STRING; a_template: SIMPLE_TEMPLATE)
  require
    name_not_void: a_name /= Void
    name_not_empty: not a_name.is_empty
    template_not_void: a_template /= Void
```

### SIMPLE_TEMPLATE Context

```eiffel
set_variable (a_name: STRING; a_value: STRING)
  require
    name_not_void: a_name /= Void
    name_not_empty: not a_name.is_empty
    value_not_void: a_value /= Void

set_variable_any (a_name: STRING; a_value: ANY)
  require
    name_not_void: a_name /= Void
    name_not_empty: not a_name.is_empty
    value_not_void: a_value /= Void

set_variables (a_table: HASH_TABLE [STRING, STRING])
  require
    table_not_void: a_table /= Void

set_section (a_name: STRING; a_visible: BOOLEAN)
  require
    name_not_void: a_name /= Void
    name_not_empty: not a_name.is_empty

set_list (a_name: STRING; a_items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]])
  require
    name_not_void: a_name /= Void
    name_not_empty: not a_name.is_empty
    items_not_void: a_items /= Void

-- clear_variables: no preconditions
```

### SIMPLE_TEMPLATE Rendering

```eiffel
-- render: no preconditions

render_to_file (a_path: STRING)
  require
    path_not_void: a_path /= Void
    path_not_empty: not a_path.is_empty
```

### SIMPLE_TEMPLATE_QUICK

```eiffel
render (a_template: STRING; a_vars: HASH_TABLE [STRING, STRING])
  require
    template_not_void: a_template /= Void
    vars_not_void: a_vars /= Void

render_raw (a_template: STRING; a_vars: HASH_TABLE [STRING, STRING])
  require
    template_not_void: a_template /= Void
    vars_not_void: a_vars /= Void

file (a_path: STRING; a_vars: HASH_TABLE [STRING, STRING])
  require
    path_not_void: a_path /= Void
    path_not_empty: not a_path.is_empty
    vars_not_void: a_vars /= Void

substitute (a_template: STRING; a_replacements: HASH_TABLE [STRING, STRING])
  require
    template_not_void: a_template /= Void
    replacements_not_void: a_replacements /= Void

render_if (a_condition: BOOLEAN; a_template: STRING; a_vars: HASH_TABLE [STRING, STRING])
  require
    template_not_void: a_template /= Void
    vars_not_void: a_vars /= Void

render_choice (a_condition: BOOLEAN; a_true_template, a_false_template: STRING;
               a_vars: HASH_TABLE [STRING, STRING])
  require
    true_template_not_void: a_true_template /= Void
    false_template_not_void: a_false_template /= Void
    vars_not_void: a_vars /= Void

render_list (a_template: STRING; a_items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]])
  require
    template_not_void: a_template /= Void
    items_not_void: a_items /= Void
```

---

## Postconditions by Feature

### SIMPLE_TEMPLATE Creation

```eiffel
make
  ensure
    empty_template: template_source.is_empty
    escape_enabled: escape_html_enabled = True
    default_policy: missing_variable_policy = Policy_empty_string
    no_variables: variables.is_empty
    no_sections: sections.is_empty
    no_lists: lists.is_empty
    no_partials: partials.is_empty

make_from_string (a_template: STRING)
  ensure
    source_set: template_source.same_string (a_template)
    escape_enabled: escape_html_enabled = True
    default_policy: missing_variable_policy = Policy_empty_string

make_from_file (a_path: STRING)
  ensure
    source_loaded: not template_source.is_empty or else last_error /= Void
    escape_enabled: escape_html_enabled = True
    default_policy: missing_variable_policy = Policy_empty_string
```

### SIMPLE_TEMPLATE Queries

```eiffel
has_variable (a_name: STRING): BOOLEAN
  ensure
    definition: Result = variables.has (a_name)

is_valid: BOOLEAN
  ensure
    balanced_sections: Result implies all_sections_balanced

required_variables: ARRAYED_LIST [STRING]
  ensure
    result_not_void: Result /= Void
```

### SIMPLE_TEMPLATE Configuration

```eiffel
set_escape_html (a_enabled: BOOLEAN)
  ensure
    escape_set: escape_html_enabled = a_enabled
    source_unchanged: template_source.same_string (old template_source)
    variables_unchanged: variables.count = old variables.count

set_missing_variable_policy (a_policy: INTEGER)
  ensure
    policy_set: missing_variable_policy = a_policy
    source_unchanged: template_source.same_string (old template_source)
    escape_unchanged: escape_html_enabled = old escape_html_enabled

register_partial (a_name: STRING; a_template: SIMPLE_TEMPLATE)
  ensure
    partial_registered: partials.has (a_name)
    partial_is_template: partials.item (a_name) = a_template
    source_unchanged: template_source.same_string (old template_source)
```

### SIMPLE_TEMPLATE Context

```eiffel
set_variable (a_name: STRING; a_value: STRING)
  ensure
    variable_set: has_variable (a_name)
    value_stored: variables.item (a_name).same_string (a_value)
    sections_unchanged: sections.count = old sections.count
    lists_unchanged: lists.count = old lists.count

set_variable_any (a_name: STRING; a_value: ANY)
  ensure
    variable_set: has_variable (a_name)
    value_converted: variables.item (a_name).same_string (a_value.out)

set_variables (a_table: HASH_TABLE [STRING, STRING])
  ensure
    all_set: across a_table as ic all has_variable (ic.key) end

set_section (a_name: STRING; a_visible: BOOLEAN)
  ensure
    section_set: sections.has (a_name)
    visibility_stored: sections.item (a_name) = a_visible
    variables_unchanged: variables.count = old variables.count
    lists_unchanged: lists.count = old lists.count

set_list (a_name: STRING; a_items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]])
  ensure
    list_set: lists.has (a_name)
    items_stored: lists.item (a_name) = a_items
    variables_unchanged: variables.count = old variables.count
    sections_unchanged: sections.count = old sections.count

clear_variables
  ensure
    variables_cleared: variables.is_empty
    sections_cleared: sections.is_empty
    lists_cleared: lists.is_empty
    source_unchanged: template_source.same_string (old template_source)
    escape_unchanged: escape_html_enabled = old escape_html_enabled
    partials_unchanged: partials.count = old partials.count
```

### SIMPLE_TEMPLATE Rendering

```eiffel
render: STRING
  ensure
    result_not_void: Result /= Void
    empty_template_empty_result: template_source.is_empty implies Result.is_empty
    plain_text_unchanged: (not template_source.has_substring ("{{"))
                          implies Result.same_string (template_source)
    source_unchanged: template_source.same_string (old template_source)
    variables_unchanged: variables.count = old variables.count

render_to_file (a_path: STRING)
  ensure
    source_unchanged: template_source.same_string (old template_source)
    variables_unchanged: variables.count = old variables.count
```

### SIMPLE_TEMPLATE_QUICK

```eiffel
render (a_template: STRING; a_vars: HASH_TABLE [STRING, STRING]): STRING
  ensure
    result_not_void: Result /= Void
    empty_template_empty_result: a_template.is_empty implies Result.is_empty

render_raw (a_template: STRING; a_vars: HASH_TABLE [STRING, STRING]): STRING
  ensure
    result_not_void: Result /= Void

file (a_path: STRING; a_vars: HASH_TABLE [STRING, STRING]): STRING
  ensure
    result_not_void: Result /= Void

substitute (a_template: STRING; a_replacements: HASH_TABLE [STRING, STRING]): STRING
  ensure
    result_not_void: Result /= Void
    all_replaced: across a_replacements as ic all
                    not Result.has_substring (ic.key)
                  end

render_if (a_condition: BOOLEAN; a_template: STRING;
           a_vars: HASH_TABLE [STRING, STRING]): STRING
  ensure
    result_not_void: Result /= Void
    false_is_empty: not a_condition implies Result.is_empty

render_choice (a_condition: BOOLEAN; a_true_template, a_false_template: STRING;
               a_vars: HASH_TABLE [STRING, STRING]): STRING
  ensure
    result_not_void: Result /= Void

render_list (a_template: STRING;
             a_items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]]): STRING
  ensure
    result_not_void: Result /= Void
    empty_list_empty_result: a_items.is_empty implies Result.is_empty
```

---

## Semantic Postconditions

These postconditions verify **meaning**, not just syntax:

| Feature | Semantic Property | Purpose |
|---------|-------------------|---------|
| `render` | Empty template → empty result | Basic sanity |
| `render` | Plain text (no tags) → unchanged | Pass-through |
| `escape_html` | No raw HTML chars remain | Security |
| `is_section_truthy` | Explicit False → falsy | Correct truthiness |
| `is_section_truthy` | Empty list → falsy | List behavior |
| `get_variable` | Found → returns exact value | Lookup correctness |
| `get_variable` | Missing + keep policy → placeholder | Policy behavior |
| `render_if` | False condition → empty | Conditional logic |
| `render_list` | Empty list → empty result | Iteration sanity |
| `substitute` | All keys replaced | Replacement complete |

---

## Contract Traceability

| Requirement | Contract |
|-------------|----------|
| FR-001 (Variable interpolation) | `render` postcondition, `get_variable` |
| FR-002 (HTML escaping default) | `make` ensure `escape_enabled`, `escape_html` postcondition |
| FR-003 (Raw output) | `render_raw` postcondition |
| FR-004 (Section rendering) | `is_section_truthy` postcondition |
| FR-005 (Inverted sections) | `is_section_truthy` (negation) |
| FR-006 (Comment removal) | Verified by tests |
| FR-007 (Partial inclusion) | `register_partial` postcondition |
| FR-008 (List iteration) | `set_list` postcondition, `render_list` |
| FR-009 (Missing variable policy) | `get_variable` postcondition |
| FR-010 (Context lookup chain) | `get_variable` postcondition |
| FR-013 (Dotted names) | Verified by tests |
| FR-019 (Circular partial) | `render_partial` require `depth_within_limit` |
| FR-NEW-003 (Empty template) | `render` ensure `empty_template_empty_result` |
| FR-NEW-004 (Whitespace trim) | Verified by tests |
| DR-001 (Source non-void) | Invariant `template_source_attached` |
| DR-003 (Escape ON default) | `make` ensure `escape_enabled` |
| DR-008 (Tables non-void) | Invariants `*_attached` |
| DR-010 (Valid policy) | Invariant `valid_policy` |

---

## Frame Specifications

| Command | Modifies | Does NOT Modify |
|---------|----------|-----------------|
| `set_escape_html` | escape_html_enabled | template_source, variables, sections, lists, partials |
| `set_missing_variable_policy` | missing_variable_policy | template_source, escape_html_enabled, variables |
| `set_variable` | variables | sections, lists, partials, template_source |
| `set_section` | sections | variables, lists, partials, template_source |
| `set_list` | lists | variables, sections, partials, template_source |
| `clear_variables` | variables, sections, lists | template_source, partials, escape_html_enabled |
| `register_partial` | partials | variables, sections, lists, template_source |
| `render` | **NOTHING** | ALL state (pure query) |
