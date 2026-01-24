# S04-FEATURE-SPECS: simple_template

**BACKWASH** | Date: 2026-01-23

## SIMPLE_TEMPLATE Features

### Creation

| Feature | Signature | Description |
|---------|-----------|-------------|
| make | | Create empty template |
| make_from_string | (template: STRING) | Create from string |
| make_from_file | (path: STRING) | Create from file |

### Configuration

| Feature | Signature | Description |
|---------|-----------|-------------|
| set_escape_html | (enabled: BOOLEAN) | Toggle escaping |
| set_missing_variable_policy | (policy: INTEGER) | Handle missing vars |
| register_partial | (name: STRING; tmpl: SIMPLE_TEMPLATE) | Add partial |

### Context Building

| Feature | Signature | Description |
|---------|-----------|-------------|
| set_variable | (name, value: STRING) | Set variable |
| set_variable_any | (name: STRING; value: ANY) | Set from any |
| set_variables | (table: HASH_TABLE) | Set multiple |
| set_section | (name: STRING; visible: BOOLEAN) | Set section visibility |
| set_list | (name: STRING; items: ARRAYED_LIST) | Set list data |
| clear_variables | | Clear all context |
| remove_variable | (name: STRING) | Remove single |

### Rendering

| Feature | Signature | Description |
|---------|-----------|-------------|
| render | : STRING | Render template |
| render_to_file | (path: STRING) | Render to file |
| render_with_directives | : STRING | Render with directives |
| render_compiled | : STRING | Render via AST |

### Object Integration

| Feature | Signature | Description |
|---------|-----------|-------------|
| set_variables_from_object | (obj: ANY) | Set from object fields |
| render_with_object | (obj: ANY): STRING | Render with object |

### Compilation

| Feature | Signature | Description |
|---------|-----------|-------------|
| compile | : ST_COMPILED_TEMPLATE | Compile to AST |

### Query

| Feature | Signature | Description |
|---------|-----------|-------------|
| has_variable | (name): BOOLEAN | Check variable |
| required_variables | : ARRAYED_LIST | List variables in template |
| has_directives | : BOOLEAN | Has directive syntax |
| is_valid | : BOOLEAN | No errors |
| last_error | : detachable STRING | Error message |

### Constants

| Constant | Value | Description |
|----------|-------|-------------|
| Policy_empty_string | 1 | Missing = "" |
| Policy_raise_exception | 2 | Missing = error |
| Policy_keep_placeholder | 3 | Missing = {{name}} |
| Max_partial_depth | 100 | Recursion limit |
