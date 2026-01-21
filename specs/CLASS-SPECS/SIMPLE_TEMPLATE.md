# CLASS SPECIFICATION: SIMPLE_TEMPLATE

## Identity
- **Role**: FACADE
- **Domain Concept**: Mustache-style template engine
- **Source File**: src/simple_template.e (619 lines)

## Purpose

This class represents: A complete Mustache template engine implementation
This class is responsible for: Parsing template syntax, managing context data, rendering output with HTML escaping
This class guarantees: Non-void results, proper state management via invariants

## Creation

### make
- **Signature**: () → SIMPLE_TEMPLATE
- **Purpose**: Create empty template
- **Preconditions**: NONE
- **Postconditions**: 
  - `empty_source: template_source.is_empty`
  - `escape_enabled: escape_html_enabled`
- **Initial State**: Empty template source, empty context tables, escaping enabled

### make_from_string (a_template: STRING)
- **Signature**: (STRING) → SIMPLE_TEMPLATE
- **Purpose**: Create template from string
- **Preconditions**: `template_not_void: a_template /= Void`
- **Postconditions**: `source_set: template_source.same_string (a_template)`
- **Initial State**: Template source set to input, escaping enabled

### make_from_file (a_path: STRING)
- **Signature**: (STRING) → SIMPLE_TEMPLATE
- **Purpose**: Create template from file
- **Preconditions**: 
  - `path_not_void: a_path /= Void`
  - `path_not_empty: not a_path.is_empty`
- **Postconditions**: NONE (should have postcondition about source being set)
- **Initial State**: Template source loaded from file (or empty with last_error set)

## Queries

### template_source: STRING
- **Pure**: YES
- **Purpose**: The template source string

### escape_html_enabled: BOOLEAN
- **Pure**: YES
- **Purpose**: Is HTML escaping enabled?

### missing_variable_policy: INTEGER
- **Pure**: YES
- **Purpose**: Policy for missing variables (1=empty, 2=exception, 3=placeholder)

### has_variable (a_name: STRING): BOOLEAN
- **Preconditions**: `name_not_void: a_name /= Void`
- **Postconditions**: NONE
- **Pure**: YES
- **Purpose**: Is variable defined in context?

### required_variables: ARRAYED_LIST [STRING]
- **Preconditions**: NONE
- **Postconditions**: `result_attached: Result /= Void`
- **Pure**: YES
- **Purpose**: Extract variable names from template

### is_valid: BOOLEAN
- **Pure**: YES
- **Purpose**: Is template syntactically valid (no last_error)?

### last_error: detachable STRING
- **Pure**: YES
- **Purpose**: Last error message, if any

### render: STRING
- **Preconditions**: NONE
- **Postconditions**: `result_attached: Result /= Void`
- **Pure**: NO (depends on mutable context)
- **Purpose**: Render template with current context

## Commands

### set_escape_html (a_enabled: BOOLEAN)
- **Purpose**: Enable or disable HTML escaping
- **Preconditions**: NONE
- **Postconditions**: `set: escape_html_enabled = a_enabled`
- **Modifies**: escape_html_enabled

### set_missing_variable_policy (a_policy: INTEGER)
- **Purpose**: Set policy for missing variables
- **Preconditions**: `valid_policy: a_policy = Policy_empty_string or a_policy = Policy_raise_exception or a_policy = Policy_keep_placeholder`
- **Postconditions**: `policy_set: missing_variable_policy = a_policy`
- **Modifies**: missing_variable_policy

### set_variable (a_name: STRING; a_value: STRING)
- **Purpose**: Set a variable value
- **Preconditions**: 
  - `name_not_void: a_name /= Void`
  - `name_not_empty: not a_name.is_empty`
  - `value_not_void: a_value /= Void`
- **Postconditions**: `variable_set: has_variable (a_name)`
- **Modifies**: variables table

### set_variables (a_table: HASH_TABLE [STRING, STRING])
- **Purpose**: Set multiple variables from table
- **Preconditions**: `table_not_void: a_table /= Void`
- **Postconditions**: NONE (should verify all added)
- **Modifies**: variables table

### set_section (a_name: STRING; a_visible: BOOLEAN)
- **Purpose**: Set section visibility
- **Preconditions**: 
  - `name_not_void: a_name /= Void`
  - `name_not_empty: not a_name.is_empty`
- **Postconditions**: `section_set: sections.has (a_name)`
- **Modifies**: sections table

### set_list (a_name: STRING; a_items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]])
- **Purpose**: Set list for iteration
- **Preconditions**: 
  - `name_not_void: a_name /= Void`
  - `name_not_empty: not a_name.is_empty`
  - `items_not_void: a_items /= Void`
- **Postconditions**: `list_set: lists.has (a_name)`
- **Modifies**: lists table

### clear_variables
- **Purpose**: Clear all context data
- **Preconditions**: NONE
- **Postconditions**: 
  - `variables_empty: variables.is_empty`
  - `sections_empty: sections.is_empty`
  - `lists_empty: lists.is_empty`
- **Modifies**: variables, sections, lists

### register_partial (a_name: STRING; a_template: SIMPLE_TEMPLATE)
- **Purpose**: Register a partial template
- **Preconditions**: 
  - `name_not_void: a_name /= Void`
  - `name_not_empty: not a_name.is_empty`
  - `template_not_void: a_template /= Void`
- **Postconditions**: `registered: partials.has (a_name)`
- **Modifies**: partials table

### render_to_file (a_path: STRING)
- **Purpose**: Render and write to file
- **Preconditions**: 
  - `path_not_void: a_path /= Void`
  - `path_not_empty: not a_path.is_empty`
- **Postconditions**: NONE (should verify file written)
- **Modifies**: external file

## Invariants

| Name | Expression | Meaning |
|------|------------|---------|
| template_source_attached | template_source /= Void | Template source always exists |
| variables_attached | variables /= Void | Variable table always exists |
| sections_attached | sections /= Void | Section table always exists |
| lists_attached | lists /= Void | List table always exists |
| partials_attached | partials /= Void | Partial table always exists |

## Dependencies

- **Inherits**: ANY (implicit)
- **Uses**: HASH_TABLE, ARRAYED_LIST, STRING, PLAIN_TEXT_FILE
- **Creates**: HASH_TABLE instances, STRING, PLAIN_TEXT_FILE
- **Coupling**: LOW (only EiffelBase dependencies)

## Contract Coverage

| Metric | Count | Percentage |
|--------|-------|------------|
| Features with preconditions | 12/24 | 50% |
| Features with postconditions | 12/24 | 50% |
| Has class invariant | YES | 5 invariants |

**Overall specification quality**: MODERATE

### Gaps Identified
- `make_from_file`: Missing postcondition for template_source
- `set_variables`: Missing postcondition verifying all variables added
- `render_to_file`: Missing postcondition verifying file creation
- `required_variables`: Missing precondition about template_source
