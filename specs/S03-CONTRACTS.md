# S03-CONTRACTS: simple_template

**BACKWASH** | Date: 2026-01-23

## SIMPLE_TEMPLATE Contracts

### Creation Preconditions

```eiffel
make_from_string (a_template: STRING)
    require
        template_not_void: a_template /= Void

make_from_file (a_path: STRING)
    require
        path_not_void: a_path /= Void
        path_not_empty: not a_path.is_empty
        no_parent_traversal: not a_path.has_substring ("..")
        no_absolute_unix: a_path.item (1) /= '/'
        no_windows_drive: not (a_path.item (2) = ':')
```

### Configuration Preconditions

```eiffel
set_variable (a_name: STRING; a_value: STRING)
    require
        name_not_void: a_name /= Void
        name_not_empty: not a_name.is_empty
        value_not_void: a_value /= Void

set_missing_variable_policy (a_policy: INTEGER)
    require
        valid_policy: a_policy = Policy_empty_string or
                      a_policy = Policy_raise_exception or
                      a_policy = Policy_keep_placeholder
```

### Render Postconditions

```eiffel
render: STRING
    ensure
        result_attached: Result /= Void
        source_unchanged: template_source.same_string (old template_source.twin)
        variables_count_unchanged: variables.count = old variables.count
        sections_count_unchanged: sections.count = old sections.count
        lists_count_unchanged: lists.count = old lists.count
        partials_count_unchanged: partials.count = old partials.count
        error_cleared_on_empty: template_source.is_empty implies is_valid
```

### Internal Preconditions

```eiffel
render_section (a_name: STRING; ...)
    require
        name_not_empty: not a_name.is_empty

get_variable (a_name: STRING; ...)
    require
        name_not_empty: not a_name.is_empty
```

## Class Invariant

```eiffel
invariant
    template_source_attached: template_source /= Void
    variables_attached: variables /= Void
    sections_attached: sections /= Void
    lists_attached: lists /= Void
    partials_attached: partials /= Void
    valid_policy: missing_variable_policy >= Policy_empty_string and
                  missing_variable_policy <= Policy_keep_placeholder
    non_negative_depth: partial_depth >= 0
```
