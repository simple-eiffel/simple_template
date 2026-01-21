# S04: Feature Specifications - simple_template

## Date: 2026-01-18

## Priority Features

These features have complex logic requiring detailed specification:

---

## FEATURE: SIMPLE_TEMPLATE.render

### Signature
```eiffel
render: STRING
```

### Purpose
Core rendering function that combines template source with context data to produce output.

### Behavior
Delegates to `render_template (template_source, variables)` which:
1. Scans template character by character
2. Identifies tag patterns: `{{!`, `{{{`, `{{^`, `{{#`, `{{>`, `{{`
3. Processes each tag type appropriately
4. Returns fully substituted output

### Tag Processing Order (priority)
1. `{{!...}}` - Comment (skip content)
2. `{{{...}}}` - Raw output (no escaping)
3. `{{^...}}` - Inverted section
4. `{{#...}}` - Normal section
5. `{{>...}}` - Partial inclusion
6. `{{...}}` - Variable substitution

### Code Paths
- Plain text → append directly
- Comment → skip to closing `}}`
- Raw variable → get value, append unescaped
- Section → check truthiness, render content if true
- Inverted section → render content if false
- Partial → render sub-template with current context
- Variable → get value, escape if enabled, append

### Edge Cases
- Missing closing `}}` → treat as plain text
- Empty template → empty output
- Missing variable → per policy (empty/placeholder/error)
- Nested sections → recursive rendering

### Test Coverage
- test_render_plain_text
- test_render_variable
- test_render_multiple_variables
- test_html_escape
- test_raw_unescaped
- test_section_truthy/falsy
- test_list_iteration
- test_comment
- test_partial
- test_complex_template

---

## FEATURE: SIMPLE_TEMPLATE.is_section_truthy

### Signature
```eiffel
is_section_truthy (a_name: STRING; a_context: HASH_TABLE [STRING, STRING]): BOOLEAN
```

### Purpose
Determine if a section should be rendered based on its value.

### Algorithm
1. Check explicit sections table first
2. If not found, check lists table (truthy if non-empty)
3. If not found, check context variable
4. If not found, check global variables
5. Value is truthy if: non-void AND non-empty AND not "false" AND not "0"

### Truthiness Rules
| Value | Result |
|-------|--------|
| explicit True | truthy |
| explicit False | falsy |
| non-empty list | truthy |
| empty list | falsy |
| missing | falsy |
| non-empty string | truthy |
| empty string | falsy |
| "false" | falsy |
| "0" | falsy |

### Test Coverage
- test_section_truthy
- test_section_falsy
- test_section_missing_is_falsy
- test_inverted_section_truthy
- test_inverted_section_falsy
- test_empty_list

---

## FEATURE: SIMPLE_TEMPLATE.escape_html

### Signature
```eiffel
escape_html (a_value: STRING): STRING
```

### Purpose
Convert HTML special characters to entities to prevent XSS.

### Escaping Rules
| Character | Entity |
|-----------|--------|
| & | &amp; |
| < | &lt; |
| > | &gt; |
| " | &quot; |
| ' | &#39; |

### Algorithm
Iterate through string, replace each special character with its entity.

### Test Coverage
- test_html_escape
- test_html_escape_ampersand
- test_html_escape_quotes

---

## FEATURE: SIMPLE_TEMPLATE.get_variable

### Signature
```eiffel
get_variable (a_name: STRING; a_context: HASH_TABLE [STRING, STRING]): STRING
```

### Purpose
Retrieve variable value with context lookup and missing variable handling.

### Algorithm
1. Check context parameter first
2. If not found, check global variables table
3. If still not found, apply missing_variable_policy:
   - Policy_empty_string: return ""
   - Policy_keep_placeholder: return "{{name}}"
   - Policy_raise_exception: set last_error, return ""

### Test Coverage
- test_render_variable
- test_missing_variable_empty
- test_missing_variable_placeholder

---

## FEATURE: SIMPLE_TEMPLATE.render_section

### Signature
```eiffel
render_section (a_name: STRING; a_content: STRING; a_context: HASH_TABLE [STRING, STRING]): STRING
```

### Purpose
Render a section block, handling both conditional and list iteration.

### Algorithm
1. Check if name is a list
2. If list: iterate, merge each item's context with parent, render content
3. If not list: check truthiness, render once if truthy

### Context Merging
List items inherit parent context values. Item values override parent values for same key.

### Test Coverage
- test_section_truthy/falsy
- test_list_iteration
- test_empty_list
- test_nested_sections

---

## Untested Aspects Identified

1. `make_from_file` with non-existent file
2. Deeply nested sections (>3 levels)
3. Partial with missing partial name
4. Variable with very long name
5. Template with unbalanced section tags
6. Concurrent access (SCOOP scenarios)
