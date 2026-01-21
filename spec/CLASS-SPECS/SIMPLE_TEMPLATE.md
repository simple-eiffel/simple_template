# SIMPLE_TEMPLATE Specification

## Identity

- **Name**: SIMPLE_TEMPLATE
- **Role**: FACADE
- **Responsibility**: Manage template source, context data, and rendering configuration to produce output

---

## Domain Concept

Represents the **Template** domain concept—a text document containing static content and dynamic Mustache tags that can be rendered with variable context to produce output.

---

## Inheritance

- **Inherits**: None (standalone class)
- **Inherited by**: None

---

## Genericity

```eiffel
class SIMPLE_TEMPLATE
    -- No generic parameters
```

---

## Creation

### make

```eiffel
make
    -- Create empty template with default configuration.
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

### make_from_string

```eiffel
make_from_string (a_template: STRING)
    -- Create template from string source.
  require
    template_not_void: a_template /= Void
  ensure
    source_set: template_source.same_string (a_template)
    escape_enabled: escape_html_enabled = True
    default_policy: missing_variable_policy = Policy_empty_string
  end
```

### make_from_file

```eiffel
make_from_file (a_path: STRING)
    -- Create template from file.
  require
    path_not_void: a_path /= Void
    path_not_empty: not a_path.is_empty
  ensure
    source_loaded: not template_source.is_empty or else last_error /= Void
    escape_enabled: escape_html_enabled = True
    default_policy: missing_variable_policy = Policy_empty_string
  end
```

---

## Queries

### template_source

```eiffel
template_source: STRING
    -- Current template text.
    -- Empty string if created with `make`.
  -- Guaranteed non-void by invariant
```

### has_variable

```eiffel
has_variable (a_name: STRING): BOOLEAN
    -- Is variable `a_name` defined in context?
  require
    name_not_void: a_name /= Void
  ensure
    definition: Result = variables.has (a_name)
  end
```

### is_valid

```eiffel
is_valid: BOOLEAN
    -- Is template syntactically valid?
    -- Check balanced section tags, valid syntax.
  ensure
    balanced_sections: Result implies all_sections_balanced
  end
```

### last_error

```eiffel
last_error: detachable STRING
    -- Error message from last failed operation, if any.
    -- Void indicates no error.
```

### required_variables

```eiffel
required_variables: ARRAYED_LIST [STRING]
    -- List of variable names used in template.
    -- Useful for validation before rendering.
  ensure
    result_not_void: Result /= Void
  end
```

### escape_html_enabled

```eiffel
escape_html_enabled: BOOLEAN
    -- Is HTML escaping active?
    -- Default: True (secure by default).
```

### missing_variable_policy

```eiffel
missing_variable_policy: INTEGER
    -- Current policy for undefined variables.
    -- One of: Policy_empty_string, Policy_keep_placeholder, Policy_raise_exception.
```

---

## Constants

```eiffel
Policy_empty_string: INTEGER = 1
    -- Missing variables return empty string (default, safe).

Policy_keep_placeholder: INTEGER = 2
    -- Missing variables return "{{name}}" (debugging).

Policy_raise_exception: INTEGER = 3
    -- Missing variables set `last_error` (strict).
```

---

## Commands

### Configuration

```eiffel
set_escape_html (a_enabled: BOOLEAN)
    -- Enable or disable HTML escaping.
  ensure
    escape_set: escape_html_enabled = a_enabled
    source_unchanged: template_source.same_string (old template_source)
  end

set_missing_variable_policy (a_policy: INTEGER)
    -- Set handling for undefined variables.
  require
    valid_policy: a_policy >= Policy_empty_string
                  and a_policy <= Policy_raise_exception
  ensure
    policy_set: missing_variable_policy = a_policy
  end

register_partial (a_name: STRING; a_template: SIMPLE_TEMPLATE)
    -- Register a sub-template for `{{>name}}` inclusion.
  require
    name_not_void: a_name /= Void
    name_not_empty: not a_name.is_empty
    template_not_void: a_template /= Void
  ensure
    partial_registered: partials.has (a_name)
    partial_is_template: partials.item (a_name) = a_template
  end
```

### Context: Variables

```eiffel
set_variable (a_name: STRING; a_value: STRING)
    -- Set a string variable for `{{name}}` substitution.
  require
    name_not_void: a_name /= Void
    name_not_empty: not a_name.is_empty
    value_not_void: a_value /= Void
  ensure
    variable_set: has_variable (a_name)
    value_stored: variables.item (a_name).same_string (a_value)
  end

set_variable_any (a_name: STRING; a_value: ANY)
    -- Set a variable from any object (converts via `.out`).
  require
    name_not_void: a_name /= Void
    name_not_empty: not a_name.is_empty
    value_not_void: a_value /= Void
  ensure
    variable_set: has_variable (a_name)
    value_converted: variables.item (a_name).same_string (a_value.out)
  end

set_variables (a_table: HASH_TABLE [STRING, STRING])
    -- Set multiple variables at once from a hash table.
  require
    table_not_void: a_table /= Void
  ensure
    all_set: across a_table as ic all has_variable (ic.key) end
  end
```

### Context: Sections

```eiffel
set_section (a_name: STRING; a_visible: BOOLEAN)
    -- Set section visibility for `{{#name}}...{{/name}}`.
  require
    name_not_void: a_name /= Void
    name_not_empty: not a_name.is_empty
  ensure
    section_set: sections.has (a_name)
    visibility_stored: sections.item (a_name) = a_visible
  end
```

### Context: Lists

```eiffel
set_list (a_name: STRING; a_items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]])
    -- Set list for iteration in `{{#name}}...{{/name}}`.
  require
    name_not_void: a_name /= Void
    name_not_empty: not a_name.is_empty
    items_not_void: a_items /= Void
  ensure
    list_set: lists.has (a_name)
    items_stored: lists.item (a_name) = a_items
  end

clear_variables
    -- Reset all context data (variables, sections, lists).
    -- Partials and configuration are preserved.
  ensure
    variables_cleared: variables.is_empty
    sections_cleared: sections.is_empty
    lists_cleared: lists.is_empty
    source_unchanged: template_source.same_string (old template_source)
    partials_unchanged: partials.count = old partials.count
  end
```

### Rendering

```eiffel
render: STRING
    -- Produce output from template and current context.
  ensure
    result_not_void: Result /= Void
    empty_template_empty_result: template_source.is_empty implies Result.is_empty
    plain_text_unchanged: (not template_source.has_substring ("{{"))
                          implies Result.same_string (template_source)
    state_unchanged: template_source.same_string (old template_source)
  end

render_to_file (a_path: STRING)
    -- Write rendered output directly to file.
  require
    path_not_void: a_path /= Void
    path_not_empty: not a_path.is_empty
  end
```

---

## Invariant

```eiffel
invariant
    template_source_attached: template_source /= Void
    variables_attached: variables /= Void
    sections_attached: sections /= Void
    lists_attached: lists /= Void
    partials_attached: partials /= Void
    valid_policy: missing_variable_policy >= Policy_empty_string
                  and missing_variable_policy <= Policy_raise_exception
```

---

## Implementation Notes

1. **Internal Tables**: Variables, sections, lists, and partials are stored in private HASH_TABLEs
2. **Escaping**: The `escape_html` helper converts `& < > " '` to HTML entities
3. **Partial Depth**: Track depth during partial rendering; fail if > 100 (prevent circular)
4. **Truthiness**: Section is truthy if non-void, non-empty, not "false", not "0"
5. **Lookup Chain**: get_variable checks local context first, then parent context
6. **Thread Safety**: Design is SCOOP-compatible (no shared mutable state)
