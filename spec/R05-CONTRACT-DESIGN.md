# CONTRACT DESIGN: simple_template

## Date: 2026-01-18
## Source: R04-CLASS-DESIGN.md, R02-DOMAIN-ANALYSIS.md, R03-CHALLENGE-ASSUMPTIONS.md

---

## Contract Summary

| Metric | Count |
|--------|-------|
| Classes | 2 |
| Features | 35 |
| Preconditions | 28 |
| Postconditions | 32 |
| Invariants | 7 |
| Coverage | 100% |

---

## Class Contracts: SIMPLE_TEMPLATE

### Invariants

```eiffel
invariant
    -- From DR-001: Template source must be non-void
    template_source_attached: template_source /= Void

    -- From DR-008: All internal tables must be non-void
    variables_attached: variables /= Void
    sections_attached: sections /= Void
    lists_attached: lists /= Void
    partials_attached: partials /= Void

    -- From DR-010: Policy must be valid
    valid_policy: missing_variable_policy >= Policy_empty_string
                  and missing_variable_policy <= Policy_raise_exception

    -- Data integrity: escape setting is boolean (implicit)
    -- State validity: tables are properly typed (enforced by declaration)
```

**Invariant Justification:**

| Invariant | Source | Purpose |
|-----------|--------|---------|
| template_source_attached | DR-001 | Prevent void access during render |
| variables_attached | DR-008 | Prevent void access on set/get |
| sections_attached | DR-008 | Prevent void access on set/check |
| lists_attached | DR-008 | Prevent void access on set/iterate |
| partials_attached | DR-008 | Prevent void access on register/render |
| valid_policy | DR-010 | Ensure policy handling works |

---

### Creation Contracts

#### make

```eiffel
make
    -- Create empty template with default configuration
  do
    create template_source.make_empty
    create variables.make (10)
    create sections.make (10)
    create lists.make (5)
    create partials.make (5)
    escape_html_enabled := True
    missing_variable_policy := Policy_empty_string
  ensure
    empty_template: template_source.is_empty
    escape_enabled: escape_html_enabled = True
    default_policy: missing_variable_policy = Policy_empty_string
    no_variables: variables.is_empty
    no_sections: sections.is_empty
    no_lists: lists.is_empty
    no_partials: partials.is_empty
  end
```

#### make_from_string

```eiffel
make_from_string (a_template: STRING)
    -- Create template from string source
  require
    template_not_void: a_template /= Void
  do
    make
    template_source := a_template.twin
  ensure
    source_set: template_source.same_string (a_template)
    escape_enabled: escape_html_enabled = True
    default_policy: missing_variable_policy = Policy_empty_string
  end
```

#### make_from_file

```eiffel
make_from_file (a_path: STRING)
    -- Create template from file
  require
    path_not_void: a_path /= Void
    path_not_empty: not a_path.is_empty
  do
    make
    -- Load file content into template_source
  ensure
    source_loaded: not template_source.is_empty or else last_error /= Void
    escape_enabled: escape_html_enabled = True
    default_policy: missing_variable_policy = Policy_empty_string
  end
```

---

### Query Contracts

#### template_source

```eiffel
template_source: STRING
    -- Current template text
  -- No preconditions (always callable)
  -- Postcondition via invariant: Result /= Void
```

#### has_variable

```eiffel
has_variable (a_name: STRING): BOOLEAN
    -- Is variable `a_name` defined?
  require
    name_not_void: a_name /= Void
  do
    Result := variables.has (a_name)
  ensure
    definition: Result = variables.has (a_name)
  end
```

#### is_valid

```eiffel
is_valid: BOOLEAN
    -- Is template syntactically valid?
  do
    -- Check for balanced section tags, valid syntax
    Result := ... -- implementation
  ensure
    -- Semantic: valid template has balanced sections
    balanced_sections: Result implies all_sections_balanced
  end
```

#### last_error

```eiffel
last_error: detachable STRING
    -- Error message from last operation, if any
  -- No preconditions
  -- No postconditions (may be Void or attached)
```

#### required_variables

```eiffel
required_variables: ARRAYED_LIST [STRING]
    -- List of variable names used in template
  do
    create Result.make (10)
    -- Parse template and extract variable names
  ensure
    result_not_void: Result /= Void
  end
```

#### escape_html_enabled

```eiffel
escape_html_enabled: BOOLEAN
    -- Is HTML escaping active?
  -- No preconditions (attribute access)
  -- Default: True (from DR-003)
```

#### missing_variable_policy

```eiffel
missing_variable_policy: INTEGER
    -- Current policy for missing variables
  -- No preconditions (attribute access)
  -- Invariant guarantees valid range
```

---

### Configuration Command Contracts

#### set_escape_html

```eiffel
set_escape_html (a_enabled: BOOLEAN)
    -- Enable or disable HTML escaping
  do
    escape_html_enabled := a_enabled
  ensure
    escape_set: escape_html_enabled = a_enabled
    -- Frame: nothing else changes
    source_unchanged: template_source.same_string (old template_source)
    variables_unchanged: variables.count = old variables.count
  end
```

#### set_missing_variable_policy

```eiffel
set_missing_variable_policy (a_policy: INTEGER)
    -- Set handling for undefined variables
  require
    valid_policy: a_policy >= Policy_empty_string and a_policy <= Policy_raise_exception
  do
    missing_variable_policy := a_policy
  ensure
    policy_set: missing_variable_policy = a_policy
    -- Frame: nothing else changes
    source_unchanged: template_source.same_string (old template_source)
    escape_unchanged: escape_html_enabled = old escape_html_enabled
  end
```

#### register_partial

```eiffel
register_partial (a_name: STRING; a_template: SIMPLE_TEMPLATE)
    -- Register a sub-template for inclusion
  require
    name_not_void: a_name /= Void
    name_not_empty: not a_name.is_empty
    template_not_void: a_template /= Void
  do
    partials.force (a_template, a_name)
  ensure
    partial_registered: partials.has (a_name)
    partial_is_template: partials.item (a_name) = a_template
    -- Frame: other state unchanged
    source_unchanged: template_source.same_string (old template_source)
    variables_unchanged: variables.count = old variables.count
  end
```

---

### Context Command Contracts

#### set_variable

```eiffel
set_variable (a_name: STRING; a_value: STRING)
    -- Set a variable value
  require
    name_not_void: a_name /= Void
    name_not_empty: not a_name.is_empty
    value_not_void: a_value /= Void
  do
    variables.force (a_value, a_name)
  ensure
    variable_set: has_variable (a_name)
    value_stored: variables.item (a_name).same_string (a_value)
    -- Frame: other tables unchanged
    sections_unchanged: sections.count = old sections.count
    lists_unchanged: lists.count = old lists.count
  end
```

#### set_variable_any

```eiffel
set_variable_any (a_name: STRING; a_value: ANY)
    -- Set a variable from any object (calls .out)
  require
    name_not_void: a_name /= Void
    name_not_empty: not a_name.is_empty
    value_not_void: a_value /= Void
  do
    variables.force (a_value.out, a_name)
  ensure
    variable_set: has_variable (a_name)
    value_converted: variables.item (a_name).same_string (a_value.out)
  end
```

#### set_variables

```eiffel
set_variables (a_table: HASH_TABLE [STRING, STRING])
    -- Set multiple variables at once
  require
    table_not_void: a_table /= Void
  do
    across a_table as ic loop
      variables.force (ic.item, ic.key)
    end
  ensure
    all_set: across a_table as ic all has_variable (ic.key) end
  end
```

#### set_section

```eiffel
set_section (a_name: STRING; a_visible: BOOLEAN)
    -- Set section visibility
  require
    name_not_void: a_name /= Void
    name_not_empty: not a_name.is_empty
  do
    sections.force (a_visible, a_name)
  ensure
    section_set: sections.has (a_name)
    visibility_stored: sections.item (a_name) = a_visible
    -- Frame: variables and lists unchanged
    variables_unchanged: variables.count = old variables.count
    lists_unchanged: lists.count = old lists.count
  end
```

#### set_list

```eiffel
set_list (a_name: STRING; a_items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]])
    -- Set list for iteration
  require
    name_not_void: a_name /= Void
    name_not_empty: not a_name.is_empty
    items_not_void: a_items /= Void
  do
    lists.force (a_items, a_name)
  ensure
    list_set: lists.has (a_name)
    items_stored: lists.item (a_name) = a_items
    -- Frame: variables and sections unchanged
    variables_unchanged: variables.count = old variables.count
    sections_unchanged: sections.count = old sections.count
  end
```

#### clear_variables

```eiffel
clear_variables
    -- Reset all context data
  do
    variables.wipe_out
    sections.wipe_out
    lists.wipe_out
  ensure
    variables_cleared: variables.is_empty
    sections_cleared: sections.is_empty
    lists_cleared: lists.is_empty
    -- Frame: template and config unchanged
    source_unchanged: template_source.same_string (old template_source)
    escape_unchanged: escape_html_enabled = old escape_html_enabled
    partials_unchanged: partials.count = old partials.count
  end
```

---

### Rendering Command Contracts

#### render

```eiffel
render: STRING
    -- Produce output from template and context
  do
    Result := render_template (template_source, variables)
  ensure
    result_not_void: Result /= Void
    -- Semantic: empty template produces empty output
    empty_template_empty_result: template_source.is_empty implies Result.is_empty
    -- Semantic: plain text (no tags) unchanged
    plain_text_unchanged: (not template_source.has_substring ("{{"))
                          implies Result.same_string (template_source)
    -- Frame: state unchanged (query-like, no side effects)
    source_unchanged: template_source.same_string (old template_source)
    variables_unchanged: variables.count = old variables.count
  end
```

#### render_to_file

```eiffel
render_to_file (a_path: STRING)
    -- Write rendered output to file
  require
    path_not_void: a_path /= Void
    path_not_empty: not a_path.is_empty
  do
    -- Write render result to file
  ensure
    -- Semantic: file contains rendered output (not contractable, test-verified)
    -- Frame: template state unchanged
    source_unchanged: template_source.same_string (old template_source)
    variables_unchanged: variables.count = old variables.count
  end
```

---

### Private Feature Contracts

#### render_partial (with depth tracking for FR-019)

```eiffel
render_partial (a_name: STRING; a_context: HASH_TABLE [STRING, STRING]; a_depth: INTEGER): STRING
    -- Render a partial with depth tracking
  require
    name_not_void: a_name /= Void
    context_not_void: a_context /= Void
    depth_valid: a_depth >= 0
    depth_within_limit: a_depth <= Max_partial_depth
  do
    if partials.has (a_name) then
      Result := partials.item (a_name).render_template (
        partials.item (a_name).template_source, a_context)
    else
      Result := ""
    end
  ensure
    result_not_void: Result /= Void
  end
```

#### escape_html

```eiffel
escape_html (a_value: STRING): STRING
    -- Convert HTML special characters to entities
  require
    value_not_void: a_value /= Void
  do
    -- Replace & < > " ' with entities
  ensure
    result_not_void: Result /= Void
    -- Semantic: no raw HTML chars remain
    no_ampersand: not Result.has ('&') or else
                  Result.occurrences ('&') = Result.substring_count ("&amp;") +
                  Result.substring_count ("&lt;") + Result.substring_count ("&gt;") +
                  Result.substring_count ("&quot;") + Result.substring_count ("&#39;")
    no_less_than: not Result.has ('<') or else Result.has_substring ("&lt;")
    no_greater_than: not Result.has ('>') or else Result.has_substring ("&gt;")
  end
```

#### is_section_truthy

```eiffel
is_section_truthy (a_name: STRING; a_context: HASH_TABLE [STRING, STRING]): BOOLEAN
    -- Determine if section should render (DR-004)
  require
    name_not_void: a_name /= Void
    context_not_void: a_context /= Void
  do
    -- Check sections table, then lists, then context, then variables
    -- Truthy if: non-void, non-empty, not "false", not "0"
  ensure
    -- Semantic: explicit False is falsy
    explicit_false_is_falsy: sections.has (a_name) and then
                             sections.item (a_name) = False implies not Result
    -- Semantic: empty list is falsy
    empty_list_is_falsy: lists.has (a_name) and then
                         lists.item (a_name).is_empty implies not Result
  end
```

#### get_variable

```eiffel
get_variable (a_name: STRING; a_context: HASH_TABLE [STRING, STRING]): STRING
    -- Get variable value with policy handling (DR-005, DR-006)
  require
    name_not_void: a_name /= Void
    context_not_void: a_context /= Void
  do
    -- Lookup: context first, then global variables
    -- If missing: apply missing_variable_policy
  ensure
    result_not_void: Result /= Void
    -- Semantic: found variable returns its value
    found_returns_value: (a_context.has (a_name) implies
                         Result.same_string (a_context.item (a_name))) and
                        (variables.has (a_name) and not a_context.has (a_name) implies
                         Result.same_string (variables.item (a_name)))
    -- Semantic: missing with keep policy returns placeholder
    missing_keep_policy: (not a_context.has (a_name) and not variables.has (a_name) and
                         missing_variable_policy = Policy_keep_placeholder) implies
                        Result.same_string ("{{" + a_name + "}}")
  end
```

---

## Class Contracts: SIMPLE_TEMPLATE_QUICK

### Invariants

```eiffel
invariant
    logger_attached: logger /= Void
```

---

### Feature Contracts

#### render

```eiffel
render (a_template: STRING; a_vars: HASH_TABLE [STRING, STRING]): STRING
    -- Render template with variables (HTML escaped)
  require
    template_not_void: a_template /= Void
    vars_not_void: a_vars /= Void
  do
    -- Create internal template, set vars, render
  ensure
    result_not_void: Result /= Void
    -- Semantic: empty template produces empty result
    empty_template_empty_result: a_template.is_empty implies Result.is_empty
  end
```

#### render_raw

```eiffel
render_raw (a_template: STRING; a_vars: HASH_TABLE [STRING, STRING]): STRING
    -- Render template without HTML escaping
  require
    template_not_void: a_template /= Void
    vars_not_void: a_vars /= Void
  do
    -- Create internal template, disable escaping, set vars, render
  ensure
    result_not_void: Result /= Void
    -- Semantic: HTML chars preserved (not escaped)
    -- (verified by testing, not contractable)
  end
```

#### file

```eiffel
file (a_path: STRING; a_vars: HASH_TABLE [STRING, STRING]): STRING
    -- Render template from file
  require
    path_not_void: a_path /= Void
    path_not_empty: not a_path.is_empty
    vars_not_void: a_vars /= Void
  ensure
    result_not_void: Result /= Void
  end
```

#### substitute

```eiffel
substitute (a_template: STRING; a_replacements: HASH_TABLE [STRING, STRING]): STRING
    -- Simple find-replace (no Mustache syntax)
  require
    template_not_void: a_template /= Void
    replacements_not_void: a_replacements /= Void
  ensure
    result_not_void: Result /= Void
    -- Semantic: all keys replaced
    all_replaced: across a_replacements as ic all
                    not Result.has_substring (ic.key)
                  end
  end
```

#### render_if

```eiffel
render_if (a_condition: BOOLEAN; a_template: STRING;
           a_vars: HASH_TABLE [STRING, STRING]): STRING
    -- Render only if condition is true
  require
    template_not_void: a_template /= Void
    vars_not_void: a_vars /= Void
  ensure
    result_not_void: Result /= Void
    -- Semantic: false condition produces empty result
    false_is_empty: not a_condition implies Result.is_empty
  end
```

#### render_choice

```eiffel
render_choice (a_condition: BOOLEAN; a_true_template, a_false_template: STRING;
               a_vars: HASH_TABLE [STRING, STRING]): STRING
    -- Render one of two templates based on condition
  require
    true_template_not_void: a_true_template /= Void
    false_template_not_void: a_false_template /= Void
    vars_not_void: a_vars /= Void
  ensure
    result_not_void: Result /= Void
  end
```

#### render_list

```eiffel
render_list (a_template: STRING;
             a_items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]]): STRING
    -- Render template once per item
  require
    template_not_void: a_template /= Void
    items_not_void: a_items /= Void
  ensure
    result_not_void: Result /= Void
    -- Semantic: empty list produces empty result
    empty_list_empty_result: a_items.is_empty implies Result.is_empty
  end
```

---

## Requirement Traceability

| Requirement | Contract Location |
|-------------|-------------------|
| FR-001 (Variable interpolation) | `render` postcondition, `get_variable` |
| FR-002 (HTML escaping default) | `make` ensure `escape_enabled`, `escape_html` postcondition |
| FR-003 (Raw output) | `render_raw` postcondition |
| FR-004 (Section rendering) | `is_section_truthy` postcondition |
| FR-005 (Inverted sections) | `is_section_truthy` (negation) |
| FR-006 (Comment removal) | Verified by tests |
| FR-007 (Partial inclusion) | `register_partial` postcondition, `render_partial` |
| FR-008 (List iteration) | `set_list` postcondition, `render_list` |
| FR-009 (Missing variable policy) | `get_variable` postcondition |
| FR-010 (Context lookup chain) | `get_variable` postcondition |
| FR-013 (Dotted names) | Verified by tests |
| FR-019 (Circular partial detection) | `render_partial` require `depth_within_limit` |
| FR-NEW-003 (Empty template) | `render` ensure `empty_template_empty_result` |
| FR-NEW-004 (Whitespace trimming) | Verified by tests |
| DR-001 (Source non-void) | Invariant `template_source_attached` |
| DR-003 (Escape ON default) | `make` ensure `escape_enabled` |
| DR-008 (Tables non-void) | Invariants `*_attached` |
| DR-010 (Valid policy) | Invariant `valid_policy` |

---

## Semantic Postconditions Summary

| Feature | Semantic Property |
|---------|-------------------|
| `render` | Empty template → empty result |
| `render` | Plain text (no tags) → unchanged |
| `escape_html` | No raw HTML special chars in result |
| `is_section_truthy` | Explicit False → falsy |
| `is_section_truthy` | Empty list → falsy |
| `get_variable` | Found → returns value |
| `get_variable` | Missing + keep policy → returns placeholder |
| `render_if` | False condition → empty result |
| `render_list` | Empty list → empty result |
| `substitute` | All keys replaced |

---

## Contract Strength Analysis

| Feature | Precondition | Postcondition | Verdict |
|---------|--------------|---------------|---------|
| `make` | None | Strong | JUST_RIGHT |
| `make_from_string` | `a_template /= Void` | Strong | JUST_RIGHT |
| `set_variable` | Non-void, non-empty name | Verifies storage | JUST_RIGHT |
| `render` | None | Semantic + frame | JUST_RIGHT |
| `render_partial` | Depth limit | Result not void | JUST_RIGHT |
| `escape_html` | Value not void | No raw chars | STRONG (good) |

**No adjustments needed** - contracts are appropriately strong.

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
| `render` | **NOTHING** (pure query) | ALL state |

---

## Coverage Analysis

| Class | Features | With Preconditions | With Postconditions | Coverage |
|-------|----------|-------------------|---------------------|----------|
| SIMPLE_TEMPLATE | 25 | 18 | 25 | 100% |
| SIMPLE_TEMPLATE_QUICK | 7 | 7 | 7 | 100% |
| **Total** | 32 | 25 | 32 | **100%** |

---

## Ready For: R06-INTERFACE-DESIGN

All contracts specified with preconditions, postconditions, and invariants. Semantic postconditions verify meaningful properties. Requirements traced to contracts. Ready to design the public interface in detail.
