# CLASS SPECIFICATION: SIMPLE_TEMPLATE_QUICK

## Identity
- **Role**: FACADE (simplified)
- **Domain Concept**: Zero-configuration template wrapper
- **Source File**: src/simple_template_quick.e (211 lines)

## Purpose

This class represents: A beginner-friendly template API
This class is responsible for: Providing one-liner methods that internally use SIMPLE_TEMPLATE
This class guarantees: Non-void results, logging capability

## Creation

### make
- **Signature**: () → SIMPLE_TEMPLATE_QUICK
- **Purpose**: Create quick template facade
- **Preconditions**: NONE
- **Postconditions**: `logger_exists: logger /= Void`
- **Initial State**: Logger initialized

## Queries

### render (a_template: STRING; a_vars: ARRAY [TUPLE]): STRING
- **Signature**: (STRING, ARRAY [TUPLE [name: STRING; value: STRING]]) → STRING
- **Preconditions**: `template_not_empty: not a_template.is_empty`
- **Postconditions**: `result_exists: Result /= Void`
- **Purpose**: Render template with inline variables

### render_raw (a_template: STRING; a_vars: ARRAY [TUPLE]): STRING
- **Signature**: (STRING, ARRAY [TUPLE [name: STRING; value: STRING]]) → STRING
- **Preconditions**: `template_not_empty: not a_template.is_empty`
- **Postconditions**: `result_exists: Result /= Void`
- **Purpose**: Render template without HTML escaping

### file (a_path: STRING; a_vars: ARRAY [TUPLE]): STRING
- **Signature**: (STRING, ARRAY [TUPLE [name: STRING; value: STRING]]) → STRING
- **Preconditions**: `path_not_empty: not a_path.is_empty`
- **Postconditions**: `result_exists: Result /= Void`
- **Purpose**: Render template from file

### substitute (a_template: STRING; a_replacements: ARRAY [TUPLE]): STRING
- **Signature**: (STRING, ARRAY [TUPLE [find: STRING; replace: STRING]]) → STRING
- **Preconditions**: `template_not_empty: not a_template.is_empty`
- **Postconditions**: `result_exists: Result /= Void`
- **Purpose**: Simple find-replace substitution (no Mustache)

### render_if (a_condition: BOOLEAN; a_template: STRING; a_vars: ARRAY [TUPLE]): STRING
- **Signature**: (BOOLEAN, STRING, ARRAY [TUPLE]) → STRING
- **Preconditions**: NONE
- **Postconditions**: `result_exists: Result /= Void`
- **Purpose**: Render only if condition is true

### render_choice (a_condition: BOOLEAN; a_true_template, a_false_template: STRING; a_vars: ARRAY [TUPLE]): STRING
- **Signature**: (BOOLEAN, STRING, STRING, ARRAY [TUPLE]) → STRING
- **Preconditions**: NONE
- **Postconditions**: `result_exists: Result /= Void`
- **Purpose**: Render one of two templates based on condition

### render_list (a_template: STRING; a_items: ARRAY [ARRAY [TUPLE]]): STRING
- **Signature**: (STRING, ARRAY [ARRAY [TUPLE]]) → STRING
- **Preconditions**: `template_not_empty: not a_template.is_empty`
- **Postconditions**: `result_exists: Result /= Void`
- **Purpose**: Render template once for each item set

### variables_in (a_template: STRING): ARRAYED_LIST [STRING]
- **Signature**: (STRING) → ARRAYED_LIST [STRING]
- **Preconditions**: `template_not_empty: not a_template.is_empty`
- **Postconditions**: `result_exists: Result /= Void`
- **Purpose**: Extract variable names from template

### is_valid (a_template: STRING): BOOLEAN
- **Signature**: (STRING) → BOOLEAN
- **Preconditions**: `template_not_empty: not a_template.is_empty`
- **Postconditions**: NONE
- **Purpose**: Is template syntactically valid?

## Commands

### render_to_file (a_template: STRING; a_vars: ARRAY [TUPLE]; a_output_path: STRING)
- **Purpose**: Render template and write to file
- **Preconditions**: 
  - `template_not_empty: not a_template.is_empty`
  - `path_not_empty: not a_output_path.is_empty`
- **Postconditions**: NONE (should verify file written)
- **Modifies**: external file

## Invariants

| Name | Expression | Meaning |
|------|------------|---------|
| logger_exists | logger /= Void | Logging capability always available |

## Dependencies

- **Inherits**: ANY (implicit)
- **Uses**: SIMPLE_TEMPLATE, SIMPLE_LOGGER, STRING, ARRAY, TUPLE
- **Creates**: SIMPLE_TEMPLATE instances
- **Coupling**: LOW (depends only on SIMPLE_TEMPLATE + logging)

## Contract Coverage

| Metric | Count | Percentage |
|--------|-------|------------|
| Features with preconditions | 8/10 | 80% |
| Features with postconditions | 9/10 | 90% |
| Has class invariant | YES | 1 invariant |

**Overall specification quality**: STRONG

### Gaps Identified
- `render_to_file`: Missing postcondition verifying file creation
- `render_choice`, `render_if`: Missing precondition that templates are not empty
